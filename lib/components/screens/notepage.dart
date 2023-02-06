import 'dart:async';
import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import '../../main.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class notepage extends StatefulWidget {
  const notepage({super.key, required this.ID, required this.date, required this.notifyParent, required this.category});
  final double ID;
  final String date;
  final String category;
  final Function() notifyParent;
  @override
  State<notepage> createState() => notePageState();
}


class notePageState extends State<notepage> {
  late final RecorderController recorderController;
  late final PlayerController playerController;
  late StreamSubscription<PlayerState> playerStateSubscription;
  List<double> waveformData = [];
  final stopwatch = Stopwatch();
  String recordingTime = ''; // to store value
  bool isRecording = false;
  bool recordingStarted = false;
  bool isPlaying = false;
  bool isLoading = true;
  bool hasFile = false;
  Timer? timer;

  @override
  void initState() {
    super.initState();
    _initialiseController();
    initFile();
    stopwatch.reset();
    toggleCompanyTimer(stopTimer: "true");
  }
  void _initialiseController() {
    recorderController = RecorderController()
      ..androidEncoder = AndroidEncoder.aac_eld
      ..androidOutputFormat = AndroidOutputFormat.mpeg4
      ..iosEncoder = IosEncoder.kAudioFormatMPEG4AAC
      ..bitRate = 48000
      ..sampleRate = 44100;
    playerController = PlayerController();
    playerStateSubscription = playerController.onPlayerStateChanged.listen((_) {
      if(playerController.playerState == PlayerState.stopped || playerController.playerState == PlayerState.paused){
        setState(() {
          isPlaying = false;
        });
      } else if(playerController.playerState == PlayerState.playing){
        setState(() {
          isPlaying = true;
        });
      }
    });
  }
  initFile() async {
    final directory = await getApplicationDocumentsDirectory();
    final _path = directory.path; // instead of "/storage/emulated/0"
    final date = widget.date;
    final id = widget.ID.toInt();
    final filePath = File('$_path/Audionotes/Audionote-($date)-$id.m4a');
    if(await filePath.exists()){
      print("Archivo presente");
      final directory = await getApplicationDocumentsDirectory();
      final _path = directory.path; // instead of "/storage/emulated/0"
      final date = widget.date;
      final id = widget.ID.toInt();
      final pathFile = '$_path/Audionotes/Audionote-($date)-$id.m4a';
      await playerController.preparePlayer(path: pathFile, shouldExtractWaveform: false, volume: 1.0);
      await playerController.extractWaveformData(path: pathFile, noOfSamples: 100).then((data)=>waveformData = data);
      setState(() {
        hasFile = true;
        isLoading = false;
        print(hasFile);
      });
    } else {
      print("No hay archivo");
      setState(() {
        hasFile = false;
        isLoading = false;
      });
    }
  }

  final TextEditingController titleController = TextEditingController();
  @override
  void dispose() async{
    super.dispose();
    recorderController.dispose();
    playerStateSubscription.cancel();
    playerController.dispose();
    timer?.cancel();
    stopwatch.stop();
    toggleCompanyTimer(stopTimer: "true");
    titleController.dispose();
  }
  void propertiesDialog(BuildContext context) {
    showCupertinoModalPopup<void>(
      context: context,
      builder: (BuildContext context) => CupertinoAlertDialog(
        title: const Text("Note title"),
        content: Card(
          color: Colors.transparent,
          elevation: 0.0,
          child: Column(
            children: <Widget>[
              const SizedBox(height:15),
              CupertinoTextField(
                placeholder: NoteObjectList[NoteObjectList.indexWhere(((NoteObject) => NoteObject.ID == widget.ID))].title,
                inputFormatters: [
                  LengthLimitingTextInputFormatter(35),
                ],
                controller: titleController,
              ),
            ],
          ),
        ),
        actions: <CupertinoDialogAction>[
          CupertinoDialogAction(
            /// This parameter indicates this action is the default,
            /// and turns the action's text to bold text.
            isDefaultAction: false,
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Cancel'),
          ),
          CupertinoDialogAction(
            /// This parameter indicates the action would perform
            /// a destructive action such as deletion, and turns
            /// the action's text color to red.
            isDestructiveAction: false,
            onPressed: () {
              if(titleController.text.isNotEmpty){
                Navigator.pop(context);
                final int index = NoteObjectList.indexWhere(((NoteObject) => NoteObject.ID == widget.ID));
                setState(() {
                  NoteObjectList[index].title = titleController.text;
                });
                widget.notifyParent();
              } else {
                Navigator.pop(context);
                widget.notifyParent();
              }
            },
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }
  @override
  Widget build(BuildContext context) {
    final int index = NoteObjectList.indexWhere(((NoteObject) => NoteObject.ID == widget.ID));
    return CupertinoPageScaffold(
      child: CustomScrollView(
        slivers: <Widget>[
          CupertinoSliverNavigationBar(
            // The middle widget is visible in both collapsed and expanded states.
            middle: const Text('Note'),
            // When the "middle" parameter is implemented, the larget title is only visible
            // when the CupertinoSliverNavigationBar is fully expanded.
            largeTitle: Text(NoteObjectList[index].title),
            trailing: CupertinoButton(
              onPressed: () {
                propertiesDialog(context);
              },
              padding: EdgeInsets.zero,
              child: const Icon(CupertinoIcons.pencil),
            ),
          ),
          SliverFillRemaining(
            child: isLoading
                ? const CupertinoActivityIndicator()
                : StatefulBuilder(
                builder: (BuildContext context, StateSetter setState) {
                  return Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: hasFile == false
                          ? [
                        Center(
                            child:
                            Column(
                              children: [
                                AudioWaveforms(
                                  size: Size(MediaQuery.of(context).size.width , 50),
                                  recorderController: recorderController,
                                  enableGesture: false,
                                  waveStyle: const WaveStyle(
                                    waveColor: Colors.white,
                                    showMiddleLine: true,
                                    showDurationLabel: true,
                                    extendWaveform: true
                                  ),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12.0),
                                    color: const Color(0xFF1E1B26),
                                  ),
                                  margin: const EdgeInsets.symmetric(
                                      horizontal: 15),
                                ),
                                Text(
                                  recordingTime,
                                  style: TextStyle(
                                      color: CupertinoTheme.brightnessOf(context) == Brightness.dark ? Colors.white : Colors.black
                                  ),
                                ),
                                Row(
                                  children: isRecording ? [
                                    CupertinoButton.filled(
                                      onPressed: _startOrStopRecording,
                                      child: Icon(isRecording? Icons.pause : Icons.mic),
                                    ),
                                    CupertinoButton.filled(
                                      onPressed: stopRecording,
                                      child: Icon(Icons.stop),
                                    )
                                  ] : [
                                    CupertinoButton.filled(
                                      onPressed: _startOrStopRecording,
                                      child: Icon(isRecording? Icons.pause : Icons.mic),
                                    )
                                  ],
                                )
                              ],
                            )
                        ),

                      ]
                          : [
                        Text("Ya grabado", style: TextStyle(color: CupertinoTheme.brightnessOf(context) == Brightness.dark ? Colors.white : Colors.black)),
                        AudioFileWaveforms(
                          size: Size(MediaQuery.of(context).size.width, 50),
                          enableSeekGesture: true,
                          waveformData: waveformData,
                          waveformType: WaveformType.long,
                          shouldCalculateScrolledPosition: true,
                          decoration: const BoxDecoration(
                            color: Color(0xFF1E1B26),
                          ),
                          continuousWaveform: Platform.isIOS,
                          playerController: playerController,
                          playerWaveStyle: const PlayerWaveStyle(
                            fixedWaveColor: Colors.blueAccent,
                            liveWaveColor: Colors.redAccent,
                            showSeekLine: true,
                            spacing: 6,
                          ),
                        ),
                        CupertinoButton.filled(
                          onPressed: _startOrStopPlaying,
                          child: Icon(isPlaying ? Icons.pause : Icons.play_arrow),
                        ),
                        CupertinoButton.filled(
                          onPressed: _Rewind,
                          child: const Icon(Icons.fast_rewind),
                        )
                      ]
                  ); })
          ),
        ],
      ),
    );
  }
  void _startOrStopRecording() async {
    setState(() {
      isRecording = !isRecording;
    });
    if (isRecording) {
      final directory = await getApplicationDocumentsDirectory();
      final _path = directory.path; // instead of "/storage/emulated/0"
      final date = widget.date;
      final id = widget.ID.toInt();
      File('$_path/Audionotes/Audionote-($date)-$id.m4a').createSync(recursive: true);
      final pathFile = '$_path/Audionotes/Audionote-($date)-$id.m4a';
      await recorderController.record(path: pathFile);
      toggleCompanyTimer(stopTimer: "false");
    } else if(isRecording == false) {
      toggleCompanyTimer(stopTimer: "pause");
      await recorderController.pause();
    }
  }
  void stopRecording() async {
      toggleCompanyTimer(stopTimer: "true");
      recorderController.stop();
      setState(() {
        isRecording = false;
        isLoading = true;
      });
      final directory = await getApplicationDocumentsDirectory();
      final _path = directory.path; // instead of "/storage/emulated/0"
      final date = widget.date;
      final id = widget.ID.toInt();
      final pathFile = '$_path/Audionotes/Audionote-($date)-$id.m4a';
      await playerController.preparePlayer(path: pathFile, shouldExtractWaveform: false, volume: 1.0);
      await playerController.extractWaveformData(path: pathFile, noOfSamples: 100).then((data)=>waveformData = data);
      setState(() {
        hasFile = true;
        isLoading = false;
      });
  }
  void updateStopwatch() {
    var recordingTimeFullString = stopwatch.elapsed.toString();
    var dotpos = recordingTimeFullString.lastIndexOf('.');
    String result = (dotpos != -1)? recordingTimeFullString.substring(0, dotpos): recordingTimeFullString;
    print(result);
    setState(() {
      recordingTime = result;
    });
  }
  void toggleCompanyTimer({required String stopTimer}) {
    if (stopTimer == "false") {
      timer?.cancel();
      timer = null;
      stopwatch.start();
      timer = Timer.periodic(
        const Duration(seconds: 1),
            (Timer t) => {
              updateStopwatch(),
        },
      );
    } else if (stopTimer == "true") {
      stopwatch.stop();
      timer?.cancel();
      timer = null;
      print("Timer Canceled!");
    } else if (stopTimer == "pause") {
      stopwatch.stop();
    }
  }
  void _startOrStopPlaying() async {
    if(playerController.playerState == PlayerState.initialized || playerController.playerState == PlayerState.stopped || playerController.playerState == PlayerState.paused){
      playerController.seekTo(playerController.currentScrolledDuration.value);
      print("PROBANDO PROBANDO ALERTA: ${playerController.currentScrolledDuration.value}");
      playerController.startPlayer(finishMode: FinishMode.pause);
    } else if (playerController.playerState == PlayerState.playing){
      print("PROBANDO PROBANDO ALERTA: ${playerController.currentScrolledDuration}");
      playerController.pausePlayer();
    }
  }
  void _Rewind() async {
    playerController.seekTo(0);
  }
}