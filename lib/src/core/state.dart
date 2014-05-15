part of dartrocket;

/**
 * State is an absract class that represents a state of the game.
 * 
 * For using it you need to extend the state and call it's [new State].
 * Parameters:
 * * _name: the state's name
 * * nextState: next state's name
 * **Important:** You can controll where you want to go with nextState method.
 * 
 * Member:
 * * game: this lett you acces the main game object, stateManager initalize it
 * 
 * The state has 2 methodes, but only the run must be overwritten:
 * * load(): if you want to load images, use this methode for it
 * * run(): this methods get called after everything is loaded
 * To use the state you nedd to owerwrite at least one of them.
 * 
 * There 2 **important** methode that controls the state:
 * * endState: This methodes end the state, but we can come back to this state
 * * terminateState: This kills that state, so you can not return back to this state
 * It's **important** to understand that after a terminateState
 * you can never go back to this state.
 * If you want to return to a state use endState method.
 * 
 * Example:
 *     class MyState extends State{
 *       //You can genrate it with DartEditor's quikfix
 *       MyState(String name, [String nextState]): super(name, nextState);
 *       
 *       load(){
 *        //loading stuff
 *       }
 *       
 *       run(){         
 *       
 *         //running stuff
 *         if(playerLost){
 *           //menu will be the next state and we can try again
 *           nextState = "menu";
 *           endState(); 
 *         }else{
 *           //player won so we go to the next level and never return
 *           nextState = "nextLevel";
 *           terminateState();
 *         }
 *         
 *       }
 *     }
 * 
 * */

abstract class State extends Stream<String> {

  static const String PAUSE = "PAUSE";

  StreamController<String> _controller;
  String _name;
  String _nextStateName;
  Game game;

  State(this._name, [String nextState = null]): _nextStateName = nextState {
    _controller = new StreamController<String>(onListen: _onListen, onPause:
        _onPause, onResume: _onResume, onCancel: _onCancel);
  }
  /**
   * This methode can only be used by the [StateManager].
   * */
  StreamSubscription<String> listen(void onData(String line), {void
      onError(Error error), void onDone(), bool cancelOnError}) {
    return _controller.stream.listen(onData, onError: onError, onDone: onDone,
        cancelOnError: cancelOnError);
  }

  void _onListen() {
    load();
    game.resourceManager.load().then(run());
  }

  void _onPause() {
    game.stage.removeChildren();
    game.stage.juggler.clear();
  }

  void _onResume() {
    load();
    game.resourceManager.load().then(run());


  }

  void _onCancel() {
    game.stage.removeChildren();
    game.stage.juggler.clear();
  }
  /**
   * Overwrite if you want to load resources.
   * */
  load() {}
  
  /**
   * You must overwrite this for using the state.
   * Called after load has completed. 
   * */
  run();

  String get name => _name;

  /**
   * Change the _nextState's value.
   * */
  String get nextState => _nextStateName;

  set nextState(state) => _nextStateName = state;

  /**
   * You can send message to the StateManager.
   * */
  void addMessage(message) {
    _controller.add(message);
  }

  /**
   * This methodes end the state, but we can come back to this state
   * */
  void endState() {
    _controller.add(PAUSE);
  }
  /**
   * This kills that state, so you can not return back to this state
   * */
  void terminateState() {
    _controller.close();
  }


}
