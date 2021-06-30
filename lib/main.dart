import 'dart:convert';
import 'dart:ui';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main()=> runApp(HomePage());

List<SongsList> _songsList = [];
List<SelectedSongsList> _selectedSongsList = [];
List data;
List songData;
var songsUrl = Uri.parse("http://ghazanfarabbas.androidstudent.net/apis/music/music.php");
class SongsList{
  String songName;
  String singerName;
  String songDuration;
  String songLink;

  SongsList({this.songName, this.singerName, this.songDuration, this.songLink});

  factory SongsList.fromJson(Map<String, dynamic> json){
    return new SongsList(
      songName:json["title"],
      singerName: json["singer"],
      songDuration: json["title"],
      songLink: json["link"],
    );
  }
}
class SelectedSongsList{
  String songTitle;
  String songUrl;
  String coverImage;

  SelectedSongsList({this.songTitle, this.songUrl, this.coverImage});

  factory SelectedSongsList.fromJson(Map<String, dynamic> json){
    return new SelectedSongsList(
      songTitle:json["songTitle"],
      songUrl: json["songUrl"],
      coverImage: json["image"],
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {





  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: StackBuilder(),
      ),
    );
  }
}
class StackBuilder extends StatefulWidget {
  @override
  _StackBuilderState createState() => _StackBuilderState();
}

class _StackBuilderState extends State<StackBuilder> with TickerProviderStateMixin {

  AnimationController paneController;
  AnimationController playPauseController;
  Animation<double> paneAnimation;
  Animation<double> albumImageAnimation;
  Animation<double> albumBlurAnimation;
  Animation<Color> songsContainerColorAnimation;
  Animation<Color> songsContainerTextColorAnimation;
  bool isAnimCompleted = false;
  bool isSongPlay = false;
  AudioPlayer audioPlayer = AudioPlayer();

  Duration position = new Duration();
  Duration musicLength = new Duration();


  Widget slider(){
    return Slider.adaptive(
        activeColor: songsContainerTextColorAnimation.value,
        inactiveColor: Colors.grey[350],
        value: position.inSeconds.toDouble(),
        max: musicLength.inSeconds.toDouble(),
        onChanged: (value){
          seekToSec(value.toInt());
        });
}

void seekToSec(int sec){
    Duration newPos = Duration(seconds: sec);
    audioPlayer.seek(newPos);
}

  String selectedSongTitle = "Song Title";
  String selectedUrl = "https://www.pendujatt.net/hindi-songs/song/baarish-ban-jaana-payal-dev-stebin-ben-dmjnh.html";
  String selectedSongFile = "";
  String selectedImage = "https://cdn0.iconfinder.com/data/icons/internet-2020/1080/Applemusicandroid-512.png";
  bool isSongSelected = false;
  String selectedSinger = "Singer Name";
  int songIndex = 0;

  Future<Null> getSongDetail() async{
    print("in function");
    print(selectedUrl);
    var response = await http.get(Uri.parse("http://ghazanfarabbas.androidstudent.net/apis/music/song.php?song_url="+selectedUrl));
    print("in function1");
    var songsResponse = json.decode(response.body);


    print("in function2");
    _selectedSongsList.clear();
    print("in function3");
    setState(() {
      print("in function4");
      songData = songsResponse['song'];
      for(Map songs in songData){
        _selectedSongsList.add(SelectedSongsList.fromJson(songs));
      }

      selectedSongTitle = _selectedSongsList[0].songTitle;
      selectedSongFile = _selectedSongsList[0].songUrl;
      selectedImage = _selectedSongsList[0].coverImage;

      playSong();
    });
  }



  Future<Null> getSongsList() async{
    print("in fun");
    var response = await http.get(songsUrl);
    print("in fun1");
    var songsResponse = json.decode(response.body);
    print("in fun2");
    _songsList.clear();
    print("in fun3");
    setState(() {
      print("in fun4");
      data = songsResponse['songs'];
      print("in fun 5");
      for(Map song in data){
        _songsList.add(SongsList.fromJson(song));
      }
      print("in fun6");
      print(_songsList.length);
    });
  }

  @override
  void initState(){

    super.initState();

    print("loading");
    getSongsList();
    print("Loaded");

    paneController = AnimationController(vsync: this, duration: Duration(milliseconds: 300));
    playPauseController = AnimationController(vsync: this, duration: Duration(milliseconds: 200));
    paneAnimation = Tween<double>(begin: -250,end: 0.0).animate(CurvedAnimation(parent: paneController, curve: Curves.easeIn));
    albumImageAnimation = Tween<double>(begin: 1.0,end: 0.7).animate(CurvedAnimation(parent: paneController, curve: Curves.easeIn));
    albumBlurAnimation = Tween<double>(begin: 0.0,end: 10.0).animate(CurvedAnimation(parent: paneController, curve: Curves.easeIn));
    songsContainerColorAnimation = ColorTween(begin: Colors.black87, end: Colors.white.withOpacity(0.5)).animate(paneController);
    songsContainerTextColorAnimation = ColorTween(begin: Colors.white, end: Colors.black87).animate(paneController);



  }


  animationInit(){
    if(isAnimCompleted){
      paneController.reverse();
    }else{
      paneController.forward();
    }
    isAnimCompleted = !isAnimCompleted;
  }
  playSong(){

    if(isSongSelected){
      audioPlayer.stop();
      isSongPlay = false;
    }

    if(isSongPlay){
      playPauseController.reverse();

    }else{
      playPauseController.forward();
    }
    isSongPlay = !isSongPlay;
    if(isSongPlay){
        audioPlayer.play(selectedSongFile);
        audioPlayer.onDurationChanged.listen((d) {
            setState(() {
              musicLength = d;
            });
        });
        audioPlayer.onAudioPositionChanged.listen((p) {
          setState(() {
            position = p;
          });
        });
    }else{
      audioPlayer.pause();
    }
    print("length: "+_songsList.length.toString());
  }

  Widget stackBody(BuildContext context){
    return Stack(
      fit: StackFit.expand,
      children: <Widget>[
        FractionallySizedBox(
          alignment: Alignment.topCenter,
          heightFactor: albumImageAnimation.value,
          child: Container(
            height: MediaQuery.of(context).size.height,
            decoration: BoxDecoration(image: DecorationImage(image: new NetworkImage(selectedImage),fit: BoxFit.cover)),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: albumBlurAnimation.value, sigmaY: albumBlurAnimation.value),
              child: Container(color: Colors.white.withOpacity(0.0),),
            ),
          ),
        ),
        Positioned(
          bottom: paneAnimation.value,

          child: GestureDetector(
            onTap: () {
              animationInit();
            },
            child: Container(
              alignment: Alignment.bottomCenter,
              width: MediaQuery.of(context).size.width,

              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(topLeft: Radius.circular(25.0), topRight: Radius.circular(25.0)),
                color: songsContainerColorAnimation.value,
              ),
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Container(
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              "Now Playing",
                              style: TextStyle(
                                  color:songsContainerTextColorAnimation.value
                              ),
                            ),
                          ),
                          Text(
                            selectedSongTitle,
                            style: TextStyle(
                              color:songsContainerTextColorAnimation.value,
                              fontSize: 16.0,

                            ),
                          ),
                          Text(
                            selectedSinger,
                            style: TextStyle(
                              color:songsContainerTextColorAnimation.value,
                              fontSize: 12.0,

                            ),
                          ),
                          Container(
                            width: 500,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  "${position.inMinutes}:${position.inSeconds.remainder(60)}",
                                  style: TextStyle(color: songsContainerTextColorAnimation.value),
                                ),
                                slider(),
                                Text(
                                    "${musicLength.inMinutes}:${musicLength.inSeconds.remainder(60)}",
                                  style: TextStyle(color: songsContainerTextColorAnimation.value),
                                ),
                              ],
                            ),
                          ),

                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: <Widget>[
                                Material(
                                  color: Colors.transparent,

                                  child: InkWell(
                                    onTap: (){
                                      selectedUrl = _songsList[songIndex-1].songLink;
                                      songIndex = songIndex-1;
                                      print(_songsList[songIndex].songName);
                                      selectedSinger = _songsList[songIndex].singerName;
                                      isSongSelected = true;
                                      getSongDetail();

                                    },
                                    child: Icon(
                                      Icons.skip_previous,  size: 40.0,color: songsContainerTextColorAnimation.value,
                                    ),
                                  ),
                                ),
                                Material(
                                  color: Colors.transparent,

                                  child: InkWell(
                                    onTap: (){
                                      isSongSelected = false;
                                      playSong();
                                    },
                                    child: AnimatedIcon(
                                      icon: AnimatedIcons.play_pause,
                                      progress: playPauseController,
                                      color: songsContainerTextColorAnimation.value,
                                      size: 40.0,
                                    ),
                                  ),
                                ),
                                Material(
                                  color: Colors.transparent,

                                  child: InkWell(
                                    onTap: (){
                                      selectedUrl = _songsList[songIndex+1].songLink;
                                      songIndex = songIndex+1;
                                      print(_songsList[songIndex].songName);
                                      selectedSinger = _songsList[songIndex].singerName;
                                      isSongSelected = true;
                                      getSongDetail();

                                    },
                                    child: Icon(
                                      Icons.skip_next, size: 40.0,color: songsContainerTextColorAnimation.value,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  Container(
                    height: MediaQuery.of(context).size.height/2,
                    child: ListView.builder(

                      itemCount: _songsList.length,
                      itemBuilder: (BuildContext context, index){
                        return Dismissible(
                          key: new Key("${_songsList[index]}"),
                          onDismissed: (direction){
                            _songsList.removeAt(index);
                            Scaffold.of(context).showSnackBar(new SnackBar(content: new Text("Item Dismissed"),));
                          },

                          background: new Container(
                            color: Colors.red,
                          ),
                          child: GestureDetector(
                            onTap: (){
                              setState(() {
                                selectedUrl = _songsList[index].songLink;
                                songIndex = index;
                                print(_songsList[index].songName);
                                selectedSinger = _songsList[index].singerName;
                                isSongSelected = true;
                                getSongDetail();
                              });
                            },
                            child: new Row(
                              children: <Widget>[
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Container(
                                    height: 60,
                                    width: 60,
                                    child: CircleAvatar(
                                      backgroundImage:  ExactAssetImage('assets/musicicon.png'),
                                    ),
                                  ),
                                ),
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Container(
                                      width: MediaQuery.of(context).size.width - 100,
                                      child: SingleChildScrollView(

                                        scrollDirection: Axis.horizontal,
                                        child: Text("${_songsList[index].songName}", style: TextStyle(
                                            color:songsContainerTextColorAnimation.value
                                        ),),
                                      ),
                                    ),
                                    Container(
                                      width: MediaQuery.of(context).size.width - 150,
                                      child: SingleChildScrollView(

                                        scrollDirection: Axis.horizontal,
                                        child: Text("${_songsList[index].singerName}", style: TextStyle(
                                            color:songsContainerTextColorAnimation.value
                                        ),),
                                      ),
                                    ),


                                    // Row(
                                    //   children: [
                                    //     Container(
                                    //       width: MediaQuery.of(context).size.width - 200,
                                    //       child: SingleChildScrollView(
                                    //
                                    //         scrollDirection: Axis.horizontal,
                                    //         child:
                                    //       ),
                                    //     )
                                    //   ],
                                    // )
                                  ],
                                )
                              ],
                            ),
                          )
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: AnimatedBuilder(
        animation: paneController,
        builder: (BuildContext context, widget){
          return stackBody(context);
        },
      ),
    );
  }
}


