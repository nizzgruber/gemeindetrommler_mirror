import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';

import 'DetailPage.dart';

class UserDefinedItem extends StatelessWidget {
  final String title;
  final String description;
  final Image image;

  const UserDefinedItem({super.key,
    required this.title,
    required this.description,
    required this.image,
  });

  @override
  Widget build(BuildContext context) {
    String shortDescription = "${description.substring(0, 30)}...";
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: ListTile(
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 20, // beliebige Schriftgröße
          ),
        ),
        subtitle: Text(
          shortDescription,
          style: const TextStyle(
            fontSize: 14, // beliebige Schriftgröße
          ),
        ),
        leading: Container(
          child: image,
        ),
        onTap: () {
          // Open a new window when the user taps on the list item
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DetailPage(
                title: title,
                description: description,
                image: image,
              ),
            ),
          );
        },
      ),
    );
  }
}


class NewsList extends StatelessWidget {
  const NewsList({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(

      children: [
        UserDefinedItem(
          title: 'Rosalia Kapelle',
          description: 'Kapelle bei der Ausfahrt von Oggau',
          image: Image.network('https://upload.wikimedia.org/wikipedia/commons/d/d7/Oggau_Rosaliakapelle.JPG'),
        ),
        UserDefinedItem(
          title: 'Kirche der Marktgemeinde Oggau',
          description: 'Die römisch-katholische Pfarrkirche Oggau steht abseits der Hauptstraße in einem ehemaligen ummauerten Friedhof in der Marktgemeinde Oggau am Neusiedler See im Bezirk Eisenstadt-Umgebung im Burgenland. Die der Heiligen Dreifaltigkeit und Simon Zelotes und Judas Thaddäus geweihte Pfarrkirche gehört zum Dekanat Eisenstadt-Rust in der Diözese Eisenstadt. Die Kirche steht unter Denkmalschutz.',
          image: Image.network('https://upload.wikimedia.org/wikipedia/commons/e/e6/Oggau_Kirche2.JPG'),
        ),
        UserDefinedItem(
          title: 'Gasthaus Monika',
          description: 'Herzlich willkommen im Gasthaus Monika\nDas traditionelle Gasthaus Monika in Oggau am Neusiedler See steht bereits seit vielen Jahren für Gastfreundschaft. Vor über 80 Jahren wurde das Wirtshaus erbaut und stetig modernisiert. Mit der Übernahme im Jahr 1975 hat sich Familie Gmasz es sich zur Aufgabe gemacht, ihr Wirtshaus authentisch und traditionell weiterzuführen.\nDas freundliche und kompetente Team rund um Monika Gmasz, verwöhnt seine Gäste mit guter, bodenständiger Küche in gemütlicher Atmosphäre.\nIm Juni, Juli und August haben wir für Sie auch jeden Montag geöffnet.',
          image: Image.network('https://thumbor.apps.unitecms.io/unsafe/1400x0/https://ama-media.ams3.digitaloceanspaces.com/5f4e06d582ddc/a_pov81202.jpg'),
        ),
        UserDefinedItem(
          title: 'Sebastiankeller',
          description: 'Kulinarik - Spezialitäten von Sonja und Bernhard Landauer\nGemeinsam mit meinem Sohn Bernhard und unserem Küchenteam sorgen wir für besondere und vor allem regionalen und traditionellen, kulinarischen Genüsse. Mein Mann, Ossi Landauer und das Serviceteam ist um Ihr Wohl bemüht und lässt keine Wünsche offen.\nAuf der Speisekarte des Sebastiankellers sind neben Fisch, -Grill, -Sautanzspezialitäten viele saisonale Schmankerl und auch nicht alltägliche Gerichte wie „Gebackenen Fledermäuse“ (da ist das beste Teil vom Schweinsschlögl) oder „Geschmorte Rindswangerl“, zu finden.\nÜberwiegend werden regionale Produkte, zum Teil aus eigenem Anbau verarbeitet. So kommen die Brombeeren, Zwetschen, Quitten, Hollunder oder Kürbisse aus unserem eigenen Garten. Was an Früchten zu viel ist wird, kochen wir ein, wird zu Saft verarbeitet oder destilliert.',
          image: Image.network('https://10619-2.s.cdn12.com/rests/original/315_49137159.jpg'),
        ),
        UserDefinedItem(
          title: 'Rosalia Kapelle',
          description: 'Kapelle bei der Ausfahrt von Oggau',
          image: Image.network('https://upload.wikimedia.org/wikipedia/commons/d/d7/Oggau_Rosaliakapelle.JPG'),
        ),
        UserDefinedItem(
          title: 'Rosalia Kapelle',
          description: 'Kapelle bei der Ausfahrt von Oggau',
          image: Image.network('https://upload.wikimedia.org/wikipedia/commons/d/d7/Oggau_Rosaliakapelle.JPG'),
        ),
        UserDefinedItem(
          title: 'Rosalia Kapelle',
          description: 'Kapelle bei der Ausfahrt von Oggau',
          image: Image.network('https://upload.wikimedia.org/wikipedia/commons/d/d7/Oggau_Rosaliakapelle.JPG'),
        ),
        UserDefinedItem(
          title: 'Gemeinde Amt Oggau',
          description: 'Gemeide Amt der Marktgemeinde Oggau. SPÖ regierend',
          image: Image.network('https://upload.wikimedia.org/wikipedia/commons/a/a1/Oggau_am_Neusiedler_See_-_Gemeindeamt_%2801%29.jpg'),
        ),

      ],
    );
  }
}

class IssueList extends StatelessWidget {
  const IssueList({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        UserDefinedItem(
          title: 'Licht ausgebrannt',
          description: 'Licht ist ausgebrannt in der Sebastianstraße',
          image: Image.network('https://api.ebsg.at/uploads/immo70/originals/objekt_809_oggau-am-neusiedler-see_7063_6021.jpeg',),
        ),
        UserDefinedItem(
          title: 'test2',
          description: 'Gemeide Amt der Marktgemeinde Oggau. SPÖ regierend',
          image: Image.network('https://upload.wikimedia.org/wikipedia/commons/a/a1/Oggau_am_Neusiedler_See_-_Gemeindeamt_%2801%29.jpg'),
        ),

      ],
    );
  }
}
