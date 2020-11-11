import java.util.ArrayList;
import java.util.Collections;
import java.util.HashMap;

class SPlay extends Scene{
    CTetrisEnv tetrisEnv;

    SPlay(){
        tetrisEnv = new CTetrisEnv();
    }

    void draw(){
        tetrisEnv.draw();
    }
}

class CTetrisEnv extends Component{
    TetrisController tetris;

    CTetrisEnv(){
        super();
        tetris = new TetrisCore();
    }

    void draw(){
        tetris.draw();
    }
}

class TetrisCore{
    int _WIDTH = 10;
    int _HEIGHT = 20;
    char pressedKey;
    Stage _stage = new Stage();
    TetrisMinoGenerator minoGenerator;
    char[] keyset1 = {'w','d','s','a','g','h'};

    TetrisController(){
        minoGenerator  = new TetrisMinoGenerator();
        _stage.init(_WIDTH,_HEIGHT);
    }

    void minaFlow(){
        minoGenerator.update();
        if(!_stage.isMinoMoving()){
            Mino temp = minoGenerator.takeWaitingMino(0);
            _stage.generateMino(temp);
        }

        switch(pressedKey){

        }

    }

    char pressedKey(){
        for(char sample:keyset1){
            if(sample==){

            }
        }
    }
}

class Input{
    HashMap<Character,Boolean> _states;
    Input(char[] keySet){
        _states = new HashMap<>();
        init(keySet);
    }

    void init(char[] keySet){
        for(char key:keySet){
            _states.put(key,false);
        }
    }

    boolean isKeyPressed(char key){
        return _states.get(key);
    }

    void keyStateUpdate(){

    }

    void keyPressed() {
        _states.put(keyCode, true);
    }

    void keyReleased() {
        _states.put(keyCode, false);
    }
}

class Stage extends Component{
    Coordinate _movingMinoCoordinate;
    int _movingMinoTickCount;
    boolean _minoMovingFlag;
    Mino _currentMino;
    boolean _drawFlag;
    ArrayList<ArrayList<Integer>> _stage;
    Hold hold;
    int stageWidth;
    int stageHeight;
    int HIDDEN_HEIGHT = 4;

    Stage(){
        super();
        hold = new Hold;
    }

    void init(int stageWidth,int stageHeight){
        _stage = new ArrayList<ArrayList<Integer>>();
        _minoMovingFlag = false;
        _setStageSize(stageWidth,stageHeight+HIDDEN_HEIGHT);
    }

    void _setStageSize(int stageWidth,int stageHeight){
        this.stageWidth = stageWidth;
        this.stageHeight = stageHeight;
        for(int i=0;i<stageHeight;i++){
            addLine();
        }
    }

    void addLine(){
        ArrayList<Integer> tempLine = new ArrayList<Integer>();
        for(int i=0;i<this.stageWidth;i++){
            tempLine.set(i,0);
        }
        _stage.add(tempLine);
    }


    boolean isLineFull(ArrayList<Integer> _line){
        for(Integer block:_line){
            if(block==0){ return false; }
        }
        return true;
    }

    boolean isMinoMoving(){
        return this._minoMovingFlag;
    }

    void generateMino(Mino mino){
        this._currentMino = mino;
    }

    int checkLinesFull(){
        int fullLinesAmount = 0;
        for(int i=_stage.size()-1;i<=0;i--){
            ArrayList<Integer> targetLine = _stage.get(i);
            if(isLineFull(targetLine)){
                _removeLine(i);
                _addLines(1);
                fullLinesAmount++;
            }
        }
        return fullLinesAmount;
    }

    void _removeLine(int lineNum){
        _stage.remove(lineNum);
    }

    void _addLines(int amount){
        for(int i=0;i<amount;i++){
            addLine();
        }
    }

    void moveLeft(){
        if(!isBlocksFilled(-1,0)){
            _movingMinoCoordinate.x--;
        }
    }

    void moveRight(){
        if(!isBlocksFilled(1,0)){
            _movingMinoCoordinate.x++;
        }
    }

    boolean drop(){
        if(!isBlocksFilled(0,-1)){
            _movingMinoCoordinate.y--;
            return true;
        }
        return false;
    }

    void hardDrop(){
        while(true){
            if(!drop()){
                break;
            }
        }
    }

    void hold(){
        _currentMino = hold.swap(_currentMino);
    }

    boolean isBlocksFilled(int x,int y){
        for(Coordinate coordinate:_currentMino.getCoordinate()[_currentMino.getRotateState()]){
            if(isBlockFilled(coordinate.x + x, coordinate.y + y)){
                return true;
            }
        }
        return false;
    }

    boolean isBlockFilled(int x,int y){
        if(x<0||y<0||x>this.stageWidth||y>this.stageHeight+HIDDEN_HEIGHT){
            return true;
        }
        return _stage.get(y).get(x)!=0;
    }

    boolean isLanding(){
        return true;
    }

    @override
    void draw(){

    }
}


class Hold{
    Mino mino = null;

    boolean isHoldExist(){
        return mino!=null;
    }

    Mino swap(Mino stageMino){
        if(!isHoldExist()){
            return null;
        }
        Mino mino = this.mino;
        this.mino = stageMino;
        return mino;
    }

    Mino getMino(){
        return this.mino;
    }
}

class TetrisMinoGenerator{
    ArrayList<Mino> _waitingMinoList;

    TetrisMinoGenerator(){
        _waitingMinoList = new ArrayList<Mino>();
        _generate();
    }

    void update(){
        if(_waitingMinoList.size()<10){
            _generate();
        }
    }

    void _generate(){
        ArrayList<Mino> list = new ArrayList<Mino>();
        list.add(new Mino(Mino.MinoTypes.IMino));
        list.add(new Mino(Mino.MinoTypes.OMino));
        list.add(new Mino(Mino.MinoTypes.SMino));
        list.add(new Mino(Mino.MinoTypes.ZMino));
        list.add(new Mino(Mino.MinoTypes.LMino));
        list.add(new Mino(Mino.MinoTypes.JMino));
        list.add(new Mino(Mino.MinoTypes.TMino));
        Collections.shuffle(list);
        _waitingMinoList.addAll(list);
    }

    Mino getWaitingMino(int i){
        return _waitingMinoList.get(i);
    }

    Mino takeWaitingMino(int i){
        Mino temp = _waitingMinoList.get(i);
        _waitingMinoList.remove(i);
        return temp;
    }
}

class Mino{
    int colorID;
    int _rotateState;
    Coordinate[][] _coordinate;

    enum MinoTypes {
        IMino,
        OMino,
        SMino,
        ZMino,
        LMino,
        TMino,
        JMino
    }

    Mino(MinoTypes type) {
        _rotateState = 0;
        switch(type){
            case IMino:
                this.colorID = 1;
                int[][][] temp1 = {{{-1,0},{0,0},{1,0},{2,0}},
                        {{0,-2},{0,-1},{0,0},{0,1}},
                        {{-2,0},{-1,0},{0,0},{1,0}},
                        {{0,-1},{0,0},{0,1},{0,2}}};
                buildMino(4,temp1);
                break;
            case OMino:
                this.colorID = 2;
                int[][][] temp2 = {{{-1,-1},{-1,0},{0,-1},{0,0}},
                        {{-1,-1},{-1,0},{0,-1},{0,0}},
                        {{-1,-1},{-1,0},{0,-1},{0,0}},
                        {{-1,-1},{-1,0},{0,-1},{0,0}}};
                buildMino(4,temp2);
                break;
            default:
        }
    }

    void buildMino(int amount,int[][][] data){
        Coordinate[][] coordinate = new Coordinate[amount][4];
        for(int i=0;i<4;i++){
            for(int j=0;j<amount;j++){
                coordinate[i][j] = new Coordinate(data[i][j][0],data[i][j][1]);
            }
        }
        this._coordinate = coordinate;
    }

    Coordinate[][] getCoordinate() {
        return _coordinate;
    }

    int getRotateState(){
        return this._rotateState;
    }
}

class Coordinate{
    int x;
    int y;

    Coordinate(){

    }

    Coordinate(int x,int y){
        this.x = x;
        this.y = y;
    }
}
