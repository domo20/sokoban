

import 'package:flutter/material.dart';
import 'package:flutter_joystick/flutter_joystick.dart';
import 'dart:ui' as ui;
import 'dart:typed_data';
import 'dart:async';
import 'dart:convert';
import 'package:flutter/services.dart';
var data;

int Count_H=0;
int Count_B=0;
int Count_D=0;
int Count_G=0;
String saved_count="H";
var init=false;
double joy_x=0;
var direction='null';
double perso_x=0;
double perso_y=0;
double joy_y=0;

var level_selected=0;
var ressources = Ressources();
var animationR={0:ressources.player_droite,1:ressources.player_droite_1,2:ressources.player_droite_2};
var animationG={0:ressources.player_gauche,1:ressources.player_gauche_1,2:ressources.player_gauche_2};
var animationH={0:ressources.player_haut,1:ressources.player_haut_1,2:ressources.player_haut_2};
var animationB={0:ressources.player_bas,1:ressources.player_bas_1,2:ressources.player_bas_2};

void main() {
  runApp(const MyApp());

}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Sokoban'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}


//La classe principale
class _MyHomePageState extends State<MyHomePage>
{

  //Sert au chargement des images en mémoire

  _MyHomePageState(){
    ressources.prepare().then((value) => setState((){})); //Une fois les images chargées, on actualise
  }

  @override

  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: Text('Sokoban'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,

          children: [
            Padding(
              padding: EdgeInsets.all(5),
              child:ElevatedButton(
                child: Text('NEW GAME'),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => Game()),
                  );
                },
              ),
            ),

            Padding(
              padding: EdgeInsets.all(5),
              child:ElevatedButton(
                child: Text('QUIt'),
                onPressed: () {
                  SystemChannels.platform.invokeMethod('SystemNavigator.pop');
                },
              ),
            )

          ],
        ),
      ),
    );
  }



}
class Joystick_W  extends StatefulWidget {
  const Joystick_W({Key? key}) : super(key: key);

  @override
  Joystick_W_State createState() => Joystick_W_State();
}
class Joystick_W_State extends State<Joystick_W>
{
  JoystickMode _joystickMode = JoystickMode.all;
  Widget build(BuildContext context) {
    return Scaffold(


      body: SafeArea(
        child: Stack(
          children: [

            Align(
              alignment: Alignment.bottomRight,
              child: Joystick(
                mode: _joystickMode,

                listener: (details) {
                  print(data[level_selected]["lignes"][perso_x]);

                  setState(() {
                    joy_x =  details.x;
                    joy_y = details.y;

                    if( joy_y>0.80){
                      direction='haut';
                      print(direction);
                    }
                    else if( joy_y<-0.70){
                      direction='bas';
                      print(direction);
                    }
                    else if(joy_x>0.80){

                      direction='droite';
                      print(direction);
                    }
                    else  if(joy_x<-0.80 ){
                      direction='gauche';
                      print(direction);
                    }
                  });

                },


              ),

            ),

          ],
        ),
      ),
    );
  }
}
class Data {

  Future<String> GetData1() async {

    // Read the JSON file
    String jsonData = await rootBundle.loadString('levels.json');
    return jsonData;

  }
}

class Game extends StatelessWidget{


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          leading: PopupMenuButton(
              icon: Icon(Icons.menu),

              itemBuilder: (context) {
                return [
                  PopupMenuItem<int>(
                      value: 0,
                      child: Text("PAUSE")
                  ),
                  PopupMenuItem<int>(
                      value: 1,
                      child: Text("QUITTER")
                  )
                ];
              },
              onSelected: (value) {
                //Action en fonction du choix de l'utilisateur
              }
          ),

          actions: []
      ),

      body:
      FutureBuilder<String>(

        future:Data().GetData1(),

        builder: (context, snapshot)
        {
          if (snapshot.connectionState == ConnectionState.waiting)
          {
            return CircularProgressIndicator();

          } else if (snapshot.hasError)
          {

            return Text('Error: ${snapshot.error}');

          } else
          {

            data = jsonDecode(snapshot.data!);


            return ListView.builder(

              itemCount: data.length,
              itemBuilder: (context, index) {

                return ListTile(

                    title: Text('levels: ${(index+1).toString()}'),

                    onTap: () {
                      level_selected=index;

                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => GameScreen(level: data[index]['largeur'].toString()),
                        ),


                      );
                    }
                );
              },
            );

          }
        },
      ),

    );

  }
}


//La classe contenant les images chargées en mémoire
class Ressources {
  //Les images nécessaires au jeu, doivent se trouver dans les assets
  ui.Image? player_droite; //un des sprites du joueur
  ui.Image? caisse; //le sprite d'une caisse
  ui.Image? sol;
  ui.Image? bloc;
  ui.Image? player_haut;
  ui.Image? player_haut_1;
  ui.Image? player_haut_2;
  ui.Image? player_bas;
  ui.Image? player_bas_1;
  ui.Image? player_bas_2;
  ui.Image? player_droite_1;
  ui.Image? player_droite_2;
  ui.Image? player_gauche;
  ui.Image? player_gauche_1;
  ui.Image? player_gauche_2;
  ui.Image? vide;
  ui.Image? cible;
  bool prepared = false;

  //Lance le chargement asynchrone des images
  Future<void> prepare() async {
    player_droite = await _loadImage('sprites/droite_0.png');
    player_droite_1 = await _loadImage('sprites/droite_1.png');
    player_droite_2 = await _loadImage('sprites/droite_2.png');
    player_gauche = await _loadImage('sprites/gauche_0.png');
    player_gauche_1 = await _loadImage('sprites/gauche_1.png');
    player_gauche_2 = await _loadImage('sprites/gauche_2.png');
    player_bas = await _loadImage('sprites/bas_0.png');
    player_bas_1 = await _loadImage('sprites/bas_1.png');
    player_bas_2 = await _loadImage('sprites/bas_2.png');
    caisse = await _loadImage('sprites/caisse.png');
    sol = await _loadImage('sprites/sol.png');
    bloc = await _loadImage('sprites/bloc.png');
    vide = await _loadImage('sprites/trou.png');
    cible = await _loadImage('sprites/cible.png');
    player_haut = await _loadImage('sprites/haut_0.png');
    prepared = true;
  }

  //Fonction de transformation d'une image asset en une image dessinable dans un canvas
  //Vous pouvez l'utiliser directement, pas besoin de la modifier pour votre projet
  Future<ui.Image> _loadImage(String fichier) async {
    ExactAssetImage assetImage = ExactAssetImage(fichier);

    AssetBundleImageKey key = await assetImage.obtainKey(ImageConfiguration());

    final ByteData data = await key.bundle.load(key.name);

    if (data == null)
      throw 'Impossible de récupérer l\'image $fichier';

    var codec = await ui.instantiateImageCodec(data.buffer.asUint8List());
    var frame = await codec.getNextFrame();

    return frame.image;
  }
}

//La zone de dessin
class MyPainter extends CustomPainter {
  double height;
  double width;
  Ressources ressources;
  bool B=false;
  bool A=false;
  MyPainter(this.height, this.width, this.ressources);
  @override
  bool updateTableau(o,p,mot,u,y)
  {


    if(data[level_selected]["lignes"][o][p]=='#')
    {
      print('False');
      return false;
    }

    else if(data[level_selected]["lignes"][o][p]=="\$")
    {
      print('False');
      return false;
    }
    else if (data[level_selected]["lignes"][o][p]==' ')
    {
      data[level_selected]["lignes"][u]=data[level_selected]["lignes"][u].replaceAll("@"," ");
      List<String> table=data[level_selected]["lignes"][o].split('');
      table[p]=mot;
      data[level_selected]["lignes"][o]=table.join('');
      return true;
    }
    return false;
  }
  @override

  @override
  int Detect_Play_Object_Collision(Canvas canvas,o,p)
  {

    for (int i = 0; i < data[level_selected]["largeur"].toInt(); i++) {
      if (i < data[level_selected]["hauteur"].toInt()) {
        for (int y = 0; y < data[level_selected]["lignes"][i].length; y++) {
          if(data[level_selected]["lignes"][i][y] == "@")
          {

            if(direction == 'droite' )
            {
              print("ok");
              if(y+1< data[level_selected]["lignes"][i].length && y+2 < data[level_selected]["lignes"][i].length) {
                if (data[level_selected]["lignes"][i][y + 1] == "\$" &&
                    data[level_selected]["lignes"][i][y + 2]) {
                  data[level_selected]["lignes"][perso_x] =
                      data[level_selected]["lignes"][perso_x].replaceAll(
                          "@", " ");
                  List<String> table = data[level_selected]["lignes"][o]
                      .split('');
                  table[p] = "@";
                  table[p+1]="\$";
                  data[level_selected]["lignes"][o] = table.join('');
                  Rect srcRect = Rect.fromLTWH(0, 0, 128, 128);
                  Rect destRect2 = Rect.fromLTWH(
                      p * 50, o * 50, 50, 50);
                  canvas.drawImageRect(
                      animationR[Count_D]!, srcRect, destRect2, Paint());
                  return 1;
                }
              }
            }
            else if(direction == 'gauche' )
            {
              if(data[level_selected]["lignes"][i][y-1] == "\$")
              {
                return -1;
              }
            }
            else if(direction == 'haut' )
            {
              if(data[level_selected]["lignes"][i][y+1] == "\$")
              {
                return 1;
              }
            }
            else if(direction == 'bas' )
            {
              if(data[level_selected]["lignes"][i][y+1] == "\$")
              {
                return -1;
              }
            }
          }
        }
      }
    }

    return 0;
  }

  @override
  void paint(Canvas canvas, Size size) {




    Rect srcRect = Rect.fromLTWH(0, 0, 128, 128);

    for (int i = 0; i < data[level_selected]["largeur"].toInt(); i++) {
      if (i < data[level_selected]["hauteur"].toInt()) {
        for (int y = 0; y < data[level_selected]["lignes"][i].length; y++) {
          Rect destRect2 = Rect.fromLTWH(y * 50, i * 50, 50, 50);
          if (data[level_selected]["lignes"][i][y] == "\$") {
            canvas.drawImageRect(
                ressources.caisse!, srcRect, destRect2, Paint());
          }


          else if (data[level_selected]["lignes"][i][y] == ".") {
            canvas.drawImageRect(
                ressources.cible!, srcRect, destRect2, Paint());
          }

          else if (data[level_selected]["lignes"][i][y] == " ") {
            canvas.drawImageRect(ressources.sol!, srcRect, destRect2, Paint());
          }
          else if (data[level_selected]["lignes"][i][y] == "#") {
            canvas.drawImageRect(ressources.bloc!, srcRect, destRect2, Paint());
          }


          else
          if (data[level_selected]["lignes"][i][y] == "@" && init == false) {
            canvas.drawImageRect(ressources.sol!, srcRect, destRect2, Paint());
            init = true;
            perso_x=i as double;
            perso_y=y as double ;
            canvas.drawImageRect(
                ressources.player_haut!, srcRect, destRect2, Paint());
          }
        }
      }
    }
    switch (direction) {
      case 'haut':
        direction='null';
        double u = perso_x;
        double y = perso_y;
        if (data[level_selected]["lignes"][perso_x][perso_y] == "@") {

          if (perso_x + 1 < data[level_selected]["largeur"].toInt()) {

            double j= perso_x + 1;





            if(updateTableau(j, perso_y, '@',u,y)==true) {
              perso_x+=1;
              Rect destRect2 = Rect.fromLTWH(
                  perso_y * 50, j * 50, 50, 50);

              canvas.drawImageRect(
                  ressources.sol!, srcRect, destRect2, Paint());
              canvas.drawImageRect(
                  animationH[Count_H]!, srcRect, destRect2, Paint());
              Count_H+=1;
              saved_count='H';
              for(int i=0;i< data[level_selected]["largeur"].toInt();i++)
              {
                if(i <data[level_selected]["hauteur"].toInt()) {
                  for(int j=0;j<data[level_selected]["lignes"][i].length;j++)
                  {

                    if (data[level_selected]["lignes"][i][j] == " ") {
                      destRect2 = Rect.fromLTWH(
                          j * 50, i * 50, 50, 50);
                      canvas.drawImageRect(
                          ressources.sol!, srcRect, destRect2, Paint());
                    }
                  }
                }
              }
            }
            else if(updateTableau(j, perso_y, "\$",u,y)==true)
            {
              Rect destRect2 = Rect.fromLTWH(
                  y * 50, u * 50, 50, 50);
              canvas.drawImageRect(
                  ressources.sol!, srcRect, destRect2, Paint());
              canvas.drawImageRect(
                  animationH[Count_H]!, srcRect, destRect2, Paint());
              saved_count='H';

              for(int i=0;i< data[level_selected]["largeur"].toInt();i++)
              {
                if(i <data[level_selected]["hauteur"].toInt()) {
                  for(int j=0;j<data[level_selected]["lignes"][i].length;j++)
                  {

                    if (data[level_selected]["lignes"][i][j] == " ") {
                      destRect2 = Rect.fromLTWH(
                          j * 50, i * 50, 50, 50);
                      canvas.drawImageRect(
                          ressources.sol!, srcRect, destRect2, Paint());
                    }
                  }
                }
              }
            }
            if(Count_H >2)
            {
              Count_H=0;
            }

          }
        }
        else
        {
          Rect destRect2 = Rect.fromLTWH(
              y * 50, u * 50, 50, 50);

          canvas.drawImageRect(
              ressources.sol!, srcRect, destRect2, Paint());
          canvas.drawImageRect(
              animationH[Count_H]!, srcRect, destRect2, Paint());
          saved_count='H';
          for(int i=0;i< data[level_selected]["largeur"].toInt();i++)
          {
            if(i <data[level_selected]["hauteur"].toInt()) {
              for(int j=0;j<data[level_selected]["lignes"][i].length;j++)
              {

                if (data[level_selected]["lignes"][i][j] == " ") {
                  destRect2 = Rect.fromLTWH(
                      j * 50, i * 50, 50, 50);
                  canvas.drawImageRect(
                      ressources.sol!, srcRect, destRect2, Paint());
                }
              }
            }
          }
        }



        break;
      case 'bas':

        direction='null';
        double u = perso_x;
        double y = perso_y;
        if (data[level_selected]["lignes"][perso_x][perso_y] == "@") {

          if (perso_x - 1 >0) {

            double j=perso_x - 1;


            if(updateTableau(j, perso_y, '@',u,y)==true) {
              perso_x-=1;
              Rect destRect2 = Rect.fromLTWH(
                  perso_y * 50, j * 50, 50, 50);

              canvas.drawImageRect(
                  ressources.sol!, srcRect, destRect2, Paint());
              canvas.drawImageRect(
                  animationB[Count_B]!, srcRect, destRect2, Paint());
              Count_B+=1;
              saved_count="B";
              for(int i=0;i< data[level_selected]["largeur"].toInt();i++)
              {
                if(i <data[level_selected]["hauteur"].toInt()) {
                  for(int j=0;j<data[level_selected]["lignes"][i].length;j++)
                  {

                    if (data[level_selected]["lignes"][i][j] == " ") {
                      destRect2 = Rect.fromLTWH(
                          j * 50, i * 50, 50, 50);
                      canvas.drawImageRect(
                          ressources.sol!, srcRect, destRect2, Paint());
                    }
                  }
                }
              }
            }
            else
            {
              Rect destRect2 = Rect.fromLTWH(
                  y * 50, u * 50, 50, 50);

              canvas.drawImageRect(
                  ressources.sol!, srcRect, destRect2, Paint());
              canvas.drawImageRect(
                  animationB[Count_B]!, srcRect, destRect2, Paint());
              saved_count="B";
              for(int i=0;i< data[level_selected]["largeur"].toInt();i++)
              {
                if(i <data[level_selected]["hauteur"].toInt()) {
                  for(int j=0;j<data[level_selected]["lignes"][i].length;j++)
                  {

                    if (data[level_selected]["lignes"][i][j] == " ") {
                      destRect2 = Rect.fromLTWH(
                          j * 50, i * 50, 50, 50);
                      canvas.drawImageRect(
                          ressources.sol!, srcRect, destRect2, Paint());
                    }
                  }
                }
              }
            }
            if(Count_B > 2)
            {
              Count_B=0;
            }
          }
        }
        else
        {
          Rect destRect2 = Rect.fromLTWH(
              y * 50, u * 50, 50, 50);

          canvas.drawImageRect(
              ressources.sol!, srcRect, destRect2, Paint());
          canvas.drawImageRect(
              animationB[Count_B]!, srcRect, destRect2, Paint());
          saved_count="B";
          for(int i=0;i< data[level_selected]["largeur"].toInt();i++)
          {
            if(i <data[level_selected]["hauteur"].toInt()) {
              for(int j=0;j<data[level_selected]["lignes"][i].length;j++)
              {

                if (data[level_selected]["lignes"][i][j] == " ") {
                  destRect2 = Rect.fromLTWH(
                      j * 50, i * 50, 50, 50);
                  canvas.drawImageRect(
                      ressources.sol!, srcRect, destRect2, Paint());
                }
              }
            }
          }
        }

        break;
      case 'droite':
        double u = perso_x;
        double y = perso_y;
        direction='null';
        if (data[level_selected]["lignes"][perso_x][perso_y] == "@") {


          if (perso_y + 1 <
              data[level_selected]["lignes"][perso_x].length) {

            double j= perso_y + 1;

            if (updateTableau(perso_x, j, '@', u, y) == true) {
              perso_y+=1;
              Rect destRect2 = Rect.fromLTWH(
                  j * 50, perso_x * 50, 50, 50);

              canvas.drawImageRect(
                  ressources.sol!, srcRect, destRect2, Paint());
              canvas.drawImageRect(
                  animationR[Count_D]!, srcRect, destRect2, Paint());
              Count_D+=1;
              saved_count="D";
              for(int i=0;i< data[level_selected]["largeur"].toInt();i++)
              {
                if(i <data[level_selected]["hauteur"].toInt()) {
                  for(int j=0;j<data[level_selected]["lignes"][i].length;j++)
                  {

                    if (data[level_selected]["lignes"][i][j] == " ") {
                      destRect2 = Rect.fromLTWH(
                          j * 50, i * 50, 50, 50);
                      canvas.drawImageRect(
                          ressources.sol!, srcRect, destRect2, Paint());
                    }
                  }
                }
              }

            }
            else
            {
              Rect destRect2 = Rect.fromLTWH(
                  y * 50, u * 50, 50, 50);
              canvas.drawImageRect(
                  ressources.sol!, srcRect, destRect2, Paint());
              canvas.drawImageRect(
                  animationR[Count_D]!, srcRect, destRect2, Paint());
              saved_count="D";
              print(Detect_Play_Object_Collision(canvas,perso_x ,j ));
              for(int i=0;i< data[level_selected]["largeur"].toInt();i++)
              {
                if(i <data[level_selected]["hauteur"].toInt()) {
                  for(int j=0;j<data[level_selected]["lignes"][i].length;j++) {
                    if (data[level_selected]["lignes"][i][j] == " ") {
                      destRect2 = Rect.fromLTWH(
                          j * 50, i * 50, 50, 50);
                      canvas.drawImageRect(
                          ressources.sol!, srcRect, destRect2, Paint());
                    }
                  }
                }
              }
            }
            if(Count_D > 2)
            {
              Count_D=0;
            }
          }

        }
        else
        {
          Rect destRect2 = Rect.fromLTWH(
              y * 50, u * 50, 50, 50);
          canvas.drawImageRect(
              ressources.sol!, srcRect, destRect2, Paint());

          canvas.drawImageRect(
              animationR[Count_D]!, srcRect, destRect2, Paint());
          saved_count="D";
          for(int i=0;i< data[level_selected]["largeur"].toInt();i++)
          {
            if(i <data[level_selected]["hauteur"].toInt()) {
              for(int j=0;j<data[level_selected]["lignes"][i].length;j++) {
                if (data[level_selected]["lignes"][i][j] == " ") {
                  destRect2 = Rect.fromLTWH(
                      j * 50, i * 50, 50, 50);
                  canvas.drawImageRect(
                      ressources.sol!, srcRect, destRect2, Paint());
                }
              }
            }
          }
        }
        break;
      case 'gauche':

        direction='null';
        double u = perso_x;
        double y = perso_y;
        if (data[level_selected]["lignes"][perso_x][perso_y] == "@") {
          if (perso_y - 1 >0) {
            double j=perso_y - 1;



            //updateTableau(perso_x, perso_y+1, ' ');

            //canvas.drawImageRect(ressources.player_haut!, srcRect, destRect2, Paint());

            if(updateTableau(perso_x, j, '@',u,y)==true) {
              perso_y-=1;
              Rect destRect2 = Rect.fromLTWH(
                  j * 50, perso_x * 50, 50, 50);
              canvas.drawImageRect(
                  ressources.sol!, srcRect, destRect2, Paint());
              canvas.drawImageRect(
                  animationG[Count_G]!, srcRect, destRect2, Paint());
              Count_G+=1;
              saved_count="G";
              for(int i=0;i< data[level_selected]["largeur"].toInt();i++)
              {
                if(i <data[level_selected]["hauteur"].toInt()) {
                  for(int j=0;j<data[level_selected]["lignes"][i].length;j++) {
                    if (data[level_selected]["lignes"][i][j] == " ") {
                      destRect2 = Rect.fromLTWH(
                          j * 50, i * 50, 50, 50);
                      canvas.drawImageRect(
                          ressources.sol!, srcRect, destRect2, Paint());
                    }
                  }
                }
              }


            }
            else
            {
              Rect destRect2 = Rect.fromLTWH(
                  y * 50, u * 50, 50, 50);
              canvas.drawImageRect(
                  ressources.sol!, srcRect, destRect2, Paint());
              canvas.drawImageRect(
                  animationG[Count_G]!, srcRect, destRect2, Paint());
              saved_count="G";

              for(int i=0;i< data[level_selected]["largeur"].toInt();i++)
              {
                if(i <data[level_selected]["hauteur"].toInt()) {
                  for(int j=0;j<data[level_selected]["lignes"][i].length;j++) {
                    if (data[level_selected]["lignes"][i][j] == " ") {
                      destRect2 = Rect.fromLTWH(
                          j * 50, i * 50, 50, 50);
                      canvas.drawImageRect(
                          ressources.sol!, srcRect, destRect2, Paint());
                    }
                  }
                }
              }

            }
            if(Count_G > 2)
            {
              Count_G=0;
            }

          }
        }
        else
        {
          Rect destRect2 = Rect.fromLTWH(
              y * 50, u * 50, 50, 50);
          canvas.drawImageRect(
              ressources.sol!, srcRect, destRect2, Paint());
          canvas.drawImageRect(
              animationG[Count_G]!, srcRect, destRect2, Paint());
          saved_count="G";

          for(int i=0;i< data[level_selected]["largeur"].toInt();i++)
          {
            if(i <data[level_selected]["hauteur"].toInt()) {
              for(int j=0;j<data[level_selected]["lignes"][i].length;j++) {
                if (data[level_selected]["lignes"][i][j] == " ") {
                  destRect2 = Rect.fromLTWH(
                      j * 50, i * 50, 50, 50);
                  canvas.drawImageRect(
                      ressources.sol!, srcRect, destRect2, Paint());
                }
              }
            }
          }
        }
        if(Count_G > 2)
        {
          Count_G=0;
        }




        break;
      default:
        Rect destRect2 = Rect.fromLTWH(
            perso_y * 50, perso_x * 50, 50, 50);

        canvas.drawImageRect(
            ressources.sol!, srcRect, destRect2, Paint());
        switch(saved_count)
        {
          case "H":
            canvas.drawImageRect(
                animationH[Count_H]!, srcRect, destRect2, Paint());
            break;
          case "B":
            canvas.drawImageRect(
                animationB[Count_B]!, srcRect, destRect2, Paint());
            break;
          case "D":
            canvas.drawImageRect(
                animationR[Count_D]!, srcRect, destRect2, Paint());
            break;
          case "G":
            canvas.drawImageRect(
                animationG[Count_G]!, srcRect, destRect2, Paint());


        }
        for(int i=0;i< data[level_selected]["largeur"].toInt();i++)
        {
          if(i <data[level_selected]["hauteur"].toInt()) {
            for(int j=0;j<data[level_selected]["lignes"][i].length;j++)
            {

              if (data[level_selected]["lignes"][i][j] == " ") {
                destRect2 = Rect.fromLTWH(
                    j * 50, i * 50, 50, 50);
                canvas.drawImageRect(
                    ressources.sol!, srcRect, destRect2, Paint());
              }
            }
          }
        }
        if(Count_G > 2)
        {
          Count_G=0;
        }
        if(Count_D > 2)
        {
          Count_D=0;
        }
        if(Count_H > 2)
        {
          Count_H=0;
        }
        if(Count_B > 2)
        {
          Count_B=0;
        }


    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}


class MyWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<Map<String, dynamic>>(
        future: loadJsonData(context, 'levels.json'),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            // Access the JSON data here
            Map<String, dynamic> jsonData = snapshot.data!;
            //String name = jsonData['name'];
            //int age = jsonData['age'];
            //List<dynamic> hobbies = jsonData['hobbies'];

            // Return your widget tree based on the loaded JSON data
            //return Text('Name: $name, Age: $age, Hobbies: $hobbies');
            return ListView.builder(
              itemCount: jsonData.length,
              itemBuilder: (context, index){
                return buildTile(jsonData[index])  ;
              },
            );
          } else if (snapshot.hasError) {
            return Text('Error loading JSON');
          }

          // Show a loading indicator while the JSON file is being loaded
          return CircularProgressIndicator();
        },
      ),
    );
  }
  buildTile(Map<String, dynamic> obj){
    return ListTile(
      title: Text('${obj['']}'),
      subtitle: Text('${obj['']}'),
      leading:  CircleAvatar(
        backgroundColor: Colors.indigo[400],
        child: Icon(Icons.money) ,
      ),
    );
  }
  Future<Map<String, dynamic>> loadJsonData(BuildContext context, String path) async {
    String jsonString = await DefaultAssetBundle.of(context).loadString(path);
    return json.decode(jsonString);
  }
}


// la classe de jeu
class GameScreen extends StatelessWidget {
  final String level;
  ScrollController scrollController = ScrollController();
  void apresConstruction() {
    scrollController.animateTo(
        scrollController.position.maxScrollExtent,
        duration: Duration(milliseconds: 500),
        curve: Curves.ease);
  }
  GameScreen({required this.level});

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) => apresConstruction());
    double hauteur = MediaQuery.of(context).size.height ;
    double largeur = MediaQuery.of(context).size.width ;
    return Scaffold(
        appBar: AppBar(
            title: Text("GameStarting"),
            leading:PopupMenuButton(
              icon:Icon(Icons.menu),
              itemBuilder: (context){
                return [
                  PopupMenuItem<int>(value:0,child: Text("Pause")),PopupMenuItem(value:1,child: Text("Quitter"))
                ];
              },
              onSelected: (value)
              {
                if(value ==0)
                {
                  Navigator.push(context,MaterialPageRoute(builder: (context)=>Game()));
                  init=false;
                }
                else if(value ==1)
                {
                  Navigator.push(context,MaterialPageRoute(builder: (context)=>MyHomePage(title:"Menu" )));
                  init=false;
                }
              },
            )
        ),
        resizeToAvoidBottomInset: true,
        body:ListView(

            children:[LayoutBuilder(
                builder: (BuildContext context, BoxConstraints constraints)
                {
                  return SingleChildScrollView(
                      controller: scrollController,

                      child: ConstrainedBox(
                          constraints: BoxConstraints(
                            minHeight: constraints.minHeight,
                            minWidth: constraints.minWidth,
                          ),
                          child: Container(
                              width: largeur, // Replace with your desired width
                              height: hauteur,
                              child: CustomPaint(

                                foregroundPainter: MyPainter(MediaQuery.of(context).size.height - 56 - 24, MediaQuery.of(context).size.width, ressources),
                                child: const Joystick_W(),


                              )


                          )
                      )


                  );
                }

            )
            ]
        )
    );



  }
}

