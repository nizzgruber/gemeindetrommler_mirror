#define _GNU_SOURCE
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <dlfcn.h>
#include <fcntl.h>
#include <stdint.h>
#include <spawn.h>

static int is_x86_64_elf(const char *path) {
    if (!path) return 0;
    int fd = open(path, O_RDONLY);
    if (fd < 0) return 0;
    unsigned char header[20];
    ssize_t n = read(fd, header, sizeof(header));
    close(fd);
    if (n < 20) return 0;
    if (header[0] != 0x7f || header[1] != 'E' || header[2] != 'L' || header[3] != 'F') return 0;
    if (header[4] != 2 || header[5] != 1) return 0;
    uint16_t machine = (uint16_t)(header[18] | (header[19] << 8));
    return machine == 62;
}

static char **build_qemu_argv(const char *pathname, char *const argv[]) {
    int argc = 0;
    while (argv && argv[argc]) argc++;
    char **new_argv = (char **)malloc((argc + 4) * sizeof(char *));
    if (!new_argv) return NULL;
    new_argv[0] = "/usr/bin/qemu-x86_64-static";
    new_argv[1] = "-L";
    new_argv[2] = "/usr/x86_64-linux-gnu";
    new_argv[3] = (char *)pathname;
    for (int i = 1; i < argc; i++) {
        new_argv[i + 3] = argv[i];
    }
    new_argv[argc + 3] = NULL;
    return new_argv;
}

int execve(const char *pathname, char *const argv[], char *const envp[]) {
    static int (*real_execve)(const char *, char *const [], char *const []) = NULL;
    if (!real_execve) real_execve = (int (*)(const char *, char *const [], char *const []))dlsym(RTLD_NEXT, "execve");
    if (pathname && is_x86_64_elf(pathname)) {
        char **new_argv = build_qemu_argv(pathname, argv);
        if (new_argv) {
            return real_execve("/usr/bin/qemu-x86_64-static", new_argv, envp);
        }
    }
    return real_execve(pathname, argv, envp);
}

int execv(const char *pathname, char *const argv[]) {
    extern char **environ;
    return execve(pathname, argv, environ);
}

int execvp(const char *file, char *const argv[]) {
    extern char **environ;
    return execve(file, argv, environ);
}

int execvpe(const char *file, char *const argv[], char *const envp[]) {
    return execve(file, argv, envp);
}

int posix_spawn(pid_t *pid, const char *path,
                const posix_spawn_file_actions_t *file_actions,
                const posix_spawnattr_t *attrp,
                char *const argv[], char *const envp[]) {
    static int (*real_posix_spawn)(pid_t *, const char *, const posix_spawn_file_actions_t *,
                                  const posix_spawnattr_t *, char *const [], char *const []) = NULL;
    if (!real_posix_spawn) {
        real_posix_spawn = (int (*)(pid_t *, const char *, const posix_spawn_file_actions_t *,
                                   const posix_spawnattr_t *, char *const [], char *const []))dlsym(RTLD_NEXT, "posix_spawn");
    }
    if (path && is_x86_64_elf(path)) {
        char **new_argv = build_qemu_argv(path, argv);
        if (new_argv) {
            return real_posix_spawn(pid, "/usr/bin/qemu-x86_64-static", file_actions, attrp, new_argv, envp);
        }
    }
    return real_posix_spawn(pid, path, file_actions, attrp, argv, envp);
}

int posix_spawnp(pid_t *pid, const char *file,
                 const posix_spawn_file_actions_t *file_actions,
                 const posix_spawnattr_t *attrp,
                 char *const argv[], char *const envp[]) {
    return posix_spawn(pid, file, file_actions, attrp, argv, envp);
}
