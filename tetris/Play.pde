import java.util.Iterator;
import java.util.Collections;

class SPlay extends Scene{
    CTetrisEnv _tetrisEnv;

    SPlay(){
        super();
    }

    @Override
    void setup(){
        super.setup();
        _tetrisEnv = new CTetrisEnv(320, 10, 640, 700);
        addComponent(_tetrisEnv);
    }

    void draw(){
        super.draw();
    }
}


/*public class CTetrisEnv {
    Scanner scanner;
    TetrisCore tetris;

    CTetrisEnv() {
        scanner = new Scanner(System.in);
        tetris = new TetrisCore();
    }

    void draw() {
        String temp2 = scanner.nextLine();
        switch (temp2) {
            case "a" -> tetris.moveLeft();
            case "d" -> tetris.moveRight();
            case "s" -> tetris.drop();
            case "g" -> tetris.leftRotate();
            case "h" -> tetris.rightRotate();
            case "w" -> tetris.hardDrop();
            case "e" -> tetris.hold();
        }
        tetris.update();
        System.out.println(tetris._movingMinoTickCount);
        printStage(tetris._stage.getStage());
        System.out.println(tetris.getScore());
    }
    //**
     *printDebug用メソッド。Stageの出力を行う。
     * /
    void printStage(ArrayList<ArrayList<Integer>> stage) {
        for (int i = 0; i < stage.size(); i++) {
            System.out.print(stage.size() - i + 9 + ": ");
            for (Integer j : stage.get(stage.size() - i - 1)) {
                System.out.print(j);
            }
            System.out.print("\n");
        }
    }
}*/




class CTetrisEnv extends Component{
    TetrisCore core;
    int RECT_SIZE = 30;

    CTetrisEnv(float x, float y, float w, float h){
        super(x, y, w, h);
        core = new TetrisCore();
    }

    @Override
    void draw(){
        // ここで描画する
        background(255,255,255);
        drawStage(this.core._stage.getStage());
        rect(_x,_y,RECT_SIZE,RECT_SIZE);
        //printStage(this.core._stage.getStage());
        core.update();

    }

    void drawStage(ArrayList<ArrayList<Integer>> stage){
        for(int i=0;i<stage.size();i++){
            for(int j=0;j<stage.get(0).size();j++){
                fill(255,255,255);
                switch(stage.get(stage.size()-i-1).get(j)){
                    case 1:
                        fill(0,255,255);
                        break;
                    case 2:
                        fill(255,255,0);
                        break;
                    case 3:
                        fill(0,255,0);
                        break;
                    case 4:
                        fill(255,0,0);
                        break;
                    case 5:
                        fill(230,121,40);
                        break;
                    case 6:
                        fill(128,0,128);
                        break;
                    case 7:
                        fill(0,0,255);
                        break;
                }
                rect(_x+RECT_SIZE*j,_y+RECT_SIZE*i+RECT_SIZE,RECT_SIZE,RECT_SIZE);
                
            }
        }
    }

    /*void drawStage(ArrayList<ArrayList<Integer>> stage) {
        for (int i = 0; i < stage.size(); i++) {
            for (Integer j : stage.get(stage.size() - i - 1)) {

                fill(255,255,255);
                rect(_x+j*RECT_SIZE,_y+RECT_SIZE+i*RECT_SIZE,RECT_SIZE,RECT_SIZE);
            }
        }
    }*/

    void printStage(ArrayList<ArrayList<Integer>> stage) {
        for (int i = 0; i < stage.size(); i++) {
            System.out.print(stage.size() - i + 9 + ": ");
            for (Integer j : stage.get(stage.size() - i - 1)) {
                System.out.print(j);
            }
            System.out.print("\n");
        }
    }
}

public class TetrisCore {
    int _DOWN_INTERVAL = 60;
    Stage _stage;
    TetrisMinoGenerator _minoGenerator;
    int _score;
    int _movingMinoTickCount;
    Mino _hold;
    boolean _holdFlag;//holdをすでに使っていたらtrue

    TetrisCore(){

        _stage = new Stage();
        _minoGenerator  = new TetrisMinoGenerator();
        _stage.minoInit(_minoGenerator.takeWaitingMino(0));
        _score = 0;
        _holdFlag = false;
        _movingMinoTickCount = 0;
    }

    /**
     * スコアを追加するメソッド。消した列の数を引数にとる。
     * @param deleteLine
     */
    void addScore(int deleteLine){
        if(deleteLine>=1) _score += 10*Math.pow(2,deleteLine-1);
    }

    int getScore(){
        return this._score;
    }

    /**
     * 毎フレーム走るメソッド。
     */
    void update(){
        _movingMinoTickCount++;
        if(_movingMinoTickCount>=_DOWN_INTERVAL){
            if(!drop()){
                placeMino();
            }
        }
    }

    /**
     * ゲームオーバーメソッド。changeSceneを行う。
     */
    void gameOver(){
        //changeScene()
        System.out.println("GameOver");
        System.exit(1);
    }

    void moveLeft(){
        _stage.moveLeft();
    }
    void moveRight(){
        _stage.moveRight();
    }
    boolean drop(){
        if(_stage.drop()){
            _movingMinoTickCount = 0;
            return true;
        }
        return false;
    }
    void hardDrop(){
        _stage.hardDrop();
        placeMino();
    }
    void rightRotate(){
        _stage.rightRotate();
    }
    void leftRotate(){
        _stage.leftRotate();
    }

    /**
     * 単純に今のミノとホールドを入れ替える。
     * その他の処理もholdには必要なためhold()から呼び出される。
     */
    void _swap(){
        if(_hold==null){
            _hold = _stage.getCurrentMino();
            _stage.minoInit(_minoGenerator.takeWaitingMino(0));
        } else{
            Mino temp = this._hold;
            _hold = _stage.getCurrentMino();
            _stage.minoInit(temp);
        }
    }

    /**
     * ホールドを行うときに呼び出すメソッド。
     */
    void hold(){
        if(!_holdFlag){
            _swap();
            this._holdFlag = true;
        }
    }

    /**
     * ミノを設置するメソッド。
     * 次のミノの準備等もここで行う。基本このメソッドで次のミノの準備まで行う。
     */
    void placeMino(){
        _stage.placeMino();
        _holdFlag = false;
        if (this._stage.isOverFromStage()) gameOver();
        this.addScore(this._stage.checkLinesFull());
        this._stage.minoInit(this._minoGenerator.takeWaitingMino(0));
        this._movingMinoTickCount = 0;
    }
}
public class Stage {
    int STAGE_WIDTH = 10;
    int STAGE_HEIGHT = 20;
    int  HIDDEN_HEIGHT = 10;
    Coordinate DEFAULT_MINO_SPAWN_COORDINATE = new Coordinate(4,19);
    ArrayList<ArrayList<Integer>> _stage;
    Mino _currentMino;
    Coordinate _currentMinoPosition;

    Stage(){
        _stage = new ArrayList<ArrayList<Integer>>();
        _setStageSize();
    }

    /**
     * ステージの大きさを指定するメソッド
     */
    void _setStageSize(){
        for(int i=0;i<STAGE_HEIGHT+HIDDEN_HEIGHT;i++){
            addLine();
        }
    }

    /**
     * ステージに一行追加するメソッド。
     */
    void addLine(){
        ArrayList<Integer> tempLine = new ArrayList<Integer>();
        for(int i=0;i<this.STAGE_WIDTH;i++){
            tempLine.add(0);
        }
        _stage.add(tempLine);
    }

    /**
     * ステージの情報(現在動いているミノを含めて)返すメソッド
     * @return
     */
    ArrayList<ArrayList<Integer>> getStage(){
        ArrayList<ArrayList<Integer>> tempStage = new ArrayList<ArrayList<Integer>>();
        for(ArrayList<Integer> i:_stage){
            ArrayList<Integer> temp = new ArrayList<Integer>();
            for(Integer j:i){
                temp.add(j);
            }
            tempStage.add(temp);
        }
        for(Coordinate coordinate:_currentMino.getCurrentShape()){
            tempStage.get(_currentMinoPosition.y+coordinate.y).set(_currentMinoPosition.x+coordinate.x,_currentMino.getColorID());
        }
        return new ArrayList<ArrayList<Integer>>(tempStage.subList(0, STAGE_HEIGHT));
    }

    /**
     * ミノの初期化に用いるメソッド
     * @param mino
     */
    void minoInit(Mino mino){
        setCurrentMino(mino);
        Coordinate position = DEFAULT_MINO_SPAWN_COORDINATE;
        this._currentMino.resetRotateIndex();
        this._currentMinoPosition = new Coordinate(position.x,position.y);
    }

    void setCurrentMino(Mino mino){
        this._currentMino = mino;
    }

    Mino getCurrentMino(){
        return this._currentMino;
    }

    void moveLeft(){
        if(!isBlocksFilled(-1,0)){
            _currentMinoPosition.x--;
        }
    }

    void moveRight(){
        if(!isBlocksFilled(1,0)){
            _currentMinoPosition.x++;
        }
    }

    boolean drop(){
        if(!isBlocksFilled(0,-1)){
            _currentMinoPosition.y--;
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

    void leftRotate(){
        if(_rotateCheck(true)){
            _currentMino.rotate(true);
        }
    }

    void rightRotate(){
        if(_rotateCheck(false)){
            _currentMino.rotate(false);
        }

    }

    /**
     * 回転した時にめり込まないかの判定.
     * めり込見そうであればfalseを返す
     */
    boolean _rotateCheck(boolean left){
        for(Coordinate coordinate:_currentMino.getLeftRotatedShape(left)){
            if(isBlockFilled(_currentMinoPosition.x+coordinate.x, _currentMinoPosition.y+coordinate.y)){
                return false;
            }
        }
        return true;
    }

    /**
     * 列が埋まっているかの判定をし、埋まっていたら消去するメソッド。
     * 返り値として消したライン数を返す
     * @return
     */
    int checkLinesFull(){
        int fullLinesAmount = 0;
        Iterator<ArrayList<Integer>> temp = _stage.iterator();
        while(temp.hasNext()){
            if(isLineFull(temp.next())){
                temp.remove();
                fullLinesAmount++;
            }
        }
        return fullLinesAmount;
    }

    /**
     * checkLinesFullで使用。
     * １列の埋まっているかの判断を行う。
     * @param _line
     * @return
     */
    boolean isLineFull(ArrayList<Integer> _line){
        for(Integer block:_line){
            if(block==0){ return false; }
        }
        return true;
    }

    /**
     * 現在のミノの座標からx,yの補正をかけた位置が埋まっているかを判別するメソッド
     * @param x
     * @param y
     * @return
     */
    boolean isBlocksFilled(int x,int y){
        for(Coordinate coordinate:_currentMino.getCurrentShape()){
            if(isBlockFilled(_currentMinoPosition.x+coordinate.x + x, _currentMinoPosition.y+coordinate.y + y)){
                return true;
            }
        }
        return false;
    }

    /**
     * x,yで示した座標がステージ外や既にブロックがあるかの判定を行う。
     * @param x
     * @param y
     * @return
     */
    boolean isBlockFilled(int x,int y){
        if(x<0||y<0||x>=this.STAGE_WIDTH||y>=this.STAGE_HEIGHT+HIDDEN_HEIGHT){
            return true;
        }
        return _stage.get(y).get(x)!=0;
    }

    /**
     * ステージから溢れていないかの判断をするメソッド
     * gameoverで使用
     * @return
     */
    boolean isOverFromStage(){
        int x = DEFAULT_MINO_SPAWN_COORDINATE.x;
        int y = DEFAULT_MINO_SPAWN_COORDINATE.y;
        return isBlockFilled(x-1,y)||isBlockFilled(x,y)||isBlockFilled(x+1,y)||isBlockFilled(x+2,y);
    }

    void placeMino(){
        for(Coordinate coordinate:_currentMino.getCurrentShape()){
            _stage.get(_currentMinoPosition.y+coordinate.y).set(_currentMinoPosition.x+coordinate.x,_currentMino.getColorID());
        }
    }
}
public class TetrisMinoGenerator {
    ArrayList<Mino> _waitingMinoList;

    TetrisMinoGenerator(){
        _waitingMinoList = new ArrayList<Mino>();
        _generate();
    }

    void _generate(){
        ArrayList<Mino> list = new ArrayList<Mino>();
        list.add(new Mino(MinoTypes.IMino));
        list.add(new Mino(MinoTypes.OMino));
        list.add(new Mino(MinoTypes.SMino));
        list.add(new Mino(MinoTypes.ZMino));
        list.add(new Mino(MinoTypes.LMino));
        list.add(new Mino(MinoTypes.JMino));
        list.add(new Mino(MinoTypes.TMino));
        Collections.shuffle(list);
        _waitingMinoList.addAll(list);
    }

    Mino getWaitingMino(int i){
        return _waitingMinoList.get(i);
    }

    Mino takeWaitingMino(int i){
        Mino temp = _waitingMinoList.get(i);
        _waitingMinoList.remove(i);
        if(_waitingMinoList.size()<10){
            _generate();
        }
        return temp;
    }
}

enum MinoTypes {
    IMino,
    OMino,
    SMino,
    ZMino,
    LMino,
    TMino,
    JMino
}
public class Mino{
    int _colorID;
    int _rotateIndex;
    Coordinate[][] _shapes;

    Mino(MinoTypes type) {
        _rotateIndex = 0;
        switch(type){
            case IMino:
                this._colorID = 1;
                _buildMino(new int[][][]
                        {{{-1,0},{0,0},{1,0},{2,0}},
                                {{0,-2},{0,-1},{0,0},{0,1}},
                                {{-2,0},{-1,0},{0,0},{1,0}},
                                {{0,-1},{0,0},{0,1},{0,2}}}
                );
                break;
            case OMino:
                this._colorID = 2;
                _buildMino(new int[][][]
                        {{{-1,-1},{-1,0},{0,-1},{0,0}},
                                {{-1,-1},{-1,0},{0,-1},{0,0}},
                                {{-1,-1},{-1,0},{0,-1},{0,0}},
                                {{-1,-1},{-1,0},{0,-1},{0,0}}}
                );
                break;
            case SMino:
                this._colorID = 3;
                _buildMino(new int[][][]
                        {{{-1,0},{0,0},{0,1},{1,1}},
                                {{1,-1},{1,0},{0,0},{0,1}},
                                {{-1,0},{0,0},{0,1},{1,1}},
                                {{1,-1},{1,0},{0,0},{0,1}}}
                );
                break;
            case ZMino:
                this._colorID = 4;
                _buildMino(new int[][][]
                        {{{-1,1},{0,1},{0,0},{1,0}},
                                {{-1,-1},{-1,0},{0,0},{0,1}},
                                {{-1,1},{0,1},{0,0},{1,0}},
                                {{-1,-1},{-1,0},{0,0},{0,1}}}
                );
                break;
            case LMino:
                this._colorID = 5;
                _buildMino(new int[][][]
                        {{{-1,0},{0,0},{1,0},{1,1}},
                                {{0,-1},{1,-1},{0,0},{0,1}},
                                {{-1,-1},{-1,0},{0,0},{1,0}},
                                {{0,-1},{0,0},{0,1},{-1,1}}}
                );
                break;
            case TMino:
                this._colorID = 6;
                _buildMino(new int[][][]
                        {{{-1,0},{0,0},{0,1},{1,0}},
                                {{0,-1},{1,0},{0,0},{0,1}},
                                {{-1,0},{0,0},{0,1},{1,0}},
                                {{0,-1},{0,0},{0,1},{-1,0}}}
                );
                break;
            case JMino:
                this._colorID = 7;
                _buildMino(new int[][][]
                        {{{-1,-1},{0,-1},{0,0},{0,1}},
                                {{-1,1},{-1,0},{0,0},{1,0}},
                                {{0,-1},{0,0},{0,1},{1,1}},
                                {{1,-1},{-1,0},{0,0},{1,0}}}
                );
                break;
            default:
                break;
        }
    }

    void resetRotateIndex(){
        this._rotateIndex = 0;
    }

    void _buildMino(int[][][] data){
        int blockSize = data[0].length;
        Coordinate[][] shapes = new Coordinate[4][blockSize];
        for(int i=0; i<4; i++){
            for(int j=0; j<blockSize; j++){
                shapes[i][j] = new Coordinate(data[i][j][0], data[i][j][1]);
            }
        }
        this._shapes = shapes;
    }

    Coordinate[] getCurrentShape(){
        return _shapes[_rotateIndex];
    }

    Coordinate[] getLeftRotatedShape(boolean leftRotate){
        int temp = _rotateIndex;
        if (leftRotate) temp--;
        else temp++;
        if (temp < 0) temp = 3;
        if (temp > 3) temp = 0;
        return _shapes[temp];
    }

    void rotate(boolean leftRotate){
        if (leftRotate) _rotateIndex--;
        else _rotateIndex++;
        if (_rotateIndex < 0) _rotateIndex = 3;
        if (_rotateIndex > 3) _rotateIndex = 0;
    }

    int getColorID(){
        return this._colorID;
    }
}
public class Coordinate {
    int x;
    int y;
    Coordinate(int x,int y){
        this.x = x;
        this.y = y;
    }
}
