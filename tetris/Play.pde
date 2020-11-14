import java.util.Iterator;
import java.util.Collections;

/** ２次元座標を表現するクラス */
class Coordinate {
    int x;
    int y;

    Coordinate(){
        this.x = 0;
        this.y = 0;
    }
    Coordinate(int x,int y){
        this.x = x;
        this.y = y;
    }
}

/** プレイシーン */
class SPlay extends Scene{
    CTetrisEnv _tetrisEnv;

    SPlay(){
        super();
    }

    @Override
    void setup(){
        super.setup();
        _tetrisEnv = new CTetrisEnv(340, 50, 600, 700, new Input());
        addComponent(_tetrisEnv);
    }

    void draw(){
        background(255,255,255);
        super.draw();

        if (_tetrisEnv.getIsGameOver()){
            println("Game Over!\nScore: " + _tetrisEnv.getScore());
            addRanking(_tetrisEnv.getScore(), _tetrisEnv.getElapsedSecs());
            app.changeScene(new SRanking(true));
        }
    }
}

/** 盤面，HOLD, NEXTを描画，ゲームロジックを管理するコンポーネント */
class CTetrisEnv extends Component{
    TetrisCore core;
    int CELL_SIZE = 30;
    long _startTime;
    int _elapsedSecs;

    CTetrisEnv(float x, float y, float w, float h, Input input){
        super(x, y, w, h);
        core = new TetrisCore(input);
    }

    @Override
    void setup(){
        super.setup();
        _startTime = System.currentTimeMillis();
    }

    @Override
    void draw(){
        super.draw();
        core.update();
        if (!core.getIsGameOver()) _elapsedSecs = (int)(Math.floor(((int)(System.currentTimeMillis() - _startTime))/1000));

        drawHold(_x, _y);
        drawScore(_x, _y+CELL_SIZE*5);
        drawTime(_x, _y+CELL_SIZE*8);
        drawStage(_x+CELL_SIZE*5, _y);
        drawNext(_x+CELL_SIZE*(5+10), _y);
    }

    // width : 10*CELL_SIZE
    void drawStage(float startX, float startY){
        ArrayList<ArrayList<Integer>> stage = core.getStage();
        for(int i=0; i<stage.size(); i++){
            for(int j=0; j<stage.get(0).size(); j++){
                int colorCode = stage.get(i).get(j);
                fill(colorCode);
                rect(startX+CELL_SIZE*j, startY+CELL_SIZE*i, CELL_SIZE, CELL_SIZE);
            }
        }
    }

    // width : 5*CELL_SIZE
    void drawHold(float startX, float startY){
        float currX = startX + (CELL_SIZE/2);
        float currY = startY + (CELL_SIZE/2);
        fill(#000000);
        textAlign(LEFT, CENTER);
        textSize(CELL_SIZE-5);
        text("HOLD", currX, currY);
        currY += CELL_SIZE + (CELL_SIZE/2);
        int[][] displayA2 = core.getHoldMino().getDisplayArray2();
        fill(core.getHoldMino().getColor());
        for (int i=0; i<4; i++){
            for (int j=0; j<2; j++){
                if (displayA2[i][j] == 1) rect(currX+CELL_SIZE*i, currY+CELL_SIZE*j, CELL_SIZE, CELL_SIZE);
            }
        }
    }

    // width : 5*CELL_SIZE
    void drawNext(float startX, float startY){
        float currX = startX+(CELL_SIZE/2);
        float currY = startY+(CELL_SIZE/2);
        fill(#000000);
        textAlign(LEFT, CENTER);
        textSize(CELL_SIZE-5);
        text("NEXT", currX, currY);
        currY += CELL_SIZE + (CELL_SIZE/2);
        Mino[] queue = core.getQueuedMino(4);
        for (Mino mino : queue){
            int[][] displayA2 = mino.getDisplayArray2();
            fill(mino.getColor());
            for (int i=0; i<4; i++){
                for (int j=0; j<2; j++){
                    if (displayA2[i][j] == 1) rect(currX+CELL_SIZE*i, currY+CELL_SIZE*j, CELL_SIZE, CELL_SIZE);
                }
            }
            currY += CELL_SIZE*2+(CELL_SIZE/2);
        }
    }

    void drawScore(float startX, float startY){
        float currX = startX;
        float currY = startY + (CELL_SIZE/2);
        fill(#000000);
        textAlign(LEFT, CENTER);
        textSize(CELL_SIZE-5);
        text("Score:\n"+core.getScore(), currX, currY);
    }

    /** 秒数をmm:ss形式にして返す */
    String formatTime(int seconds){
        int minutes = seconds / 60;
        return String.format("%02d:%02d", minutes, seconds%60);
    }

    void drawTime(float startX, float startY){
        float currX = startX;
        float currY = startY + (CELL_SIZE/2);
        fill(#000000);
        textAlign(LEFT, CENTER);
        textSize(CELL_SIZE-5);
        text("Time:\n"+formatTime(_elapsedSecs), currX, currY);
    }

    int getElapsedSecs(){
        return _elapsedSecs;
    }

    int getScore(){
        return core.getScore();
    }
    boolean getIsGameOver(){
        return core.getIsGameOver();
    }
}

class TetrisCore {
    int _DOWN_INTERVAL = 60;
    Stage _stage;
    TetrisMinoGenerator _minoGenerator;
    int _score;
    int _movingMinoTickCount;
    Mino _hold;
    boolean _holdFlag;//holdをすでに使っていたらtrue
    Input _input;
    boolean _isGameOver;

    TetrisCore(Input input){
        _isGameOver = false;
        _stage = new Stage();
        _minoGenerator  = new TetrisMinoGenerator();
        _stage.minoInit(_minoGenerator.takeWaitingMino(0));
        _score = 0;
        _holdFlag = false;
        _movingMinoTickCount = 0;
        _input = input;
        _hold = new Mino(MinoTypes.Empty);
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
    boolean getIsGameOver(){
        return _isGameOver;
    }

    ArrayList<ArrayList<Integer>> getStage(){
        return _stage.getStage();
    }

    Mino getHoldMino(){
        return _hold;
    }

    Mino[] getQueuedMino(int count){
        ArrayList<Mino> queue = new ArrayList<Mino>();
        for (int i=0; i<count; i++){
            queue.add(_minoGenerator.getWaitingMino(i));
        }
        return queue.toArray(new Mino[]{});
    }

    /**
     * 毎フレーム走るメソッド。
     */
    void update(){
        if (_isGameOver) return;
        _movingMinoTickCount++;
        if(_movingMinoTickCount>=_DOWN_INTERVAL){
            if(!drop()){
                placeMino();
            }
        }

        if (_input.isKeyPressed("drop", 5)) drop();
        if (_input.isKeyPressed("left", 20)) moveLeft();
        if (_input.isKeyPressed("right", 20)) moveRight();
        if (_input.isKeyPressed("leftRotate", 20)) leftRotate();
        if (_input.isKeyPressed("rightRotate", 20)) rightRotate();
        if (_input.isKeyTyped("hardDrop")) hardDrop();
        if (_input.isKeyTyped("hold")) hold();
    }

    void gameOver(){
        _isGameOver = true;
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
        if(_hold == null || _hold.getType() == MinoTypes.Empty){
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

class Input{
    HashMap<String, Character> DEFAULT_KEYBIND = new HashMap<String, Character>() {
        {
            put("left", 'a');
            put("right", 'd');
            put("drop", 's');
            put("hardDrop", 'w');
            put("leftRotate", 'g');
            put("rightRotate", 'h');
            put("hold", 'e');
        }
    };
    HashMap<String, Character> _keyBind;
    long _lastPressedAcceptFrame;

    Input(){
        _keyBind = DEFAULT_KEYBIND;
    }
    Input(HashMap<String, Character> bind){
        if (DEFAULT_KEYBIND.size() != bind.size()){
            println("Error: キーバインドの数が一致しません！！");
            _keyBind = DEFAULT_KEYBIND;
        }else{
            _keyBind = bind;
        }
    }

    /**
     * keyNameのキーが押されているかどうか.
     * @param keyName バインド名
     * @param intervalFrame 指定したフレームごとにしかtrueを返さない
     */
    boolean isKeyPressed(String keyName, long intervalFrame){
        if ((((Tetris)app).appElapsedFrames - _lastPressedAcceptFrame) < intervalFrame) return false;
        if (!_keyBind.containsKey(keyName)) return false;
        if (keyPressed && (key == _keyBind.get(keyName))){
            _lastPressedAcceptFrame = ((Tetris)app).appElapsedFrames;
            return true;
        }else{
            return false;
        }
    }
    boolean isKeyPressed(String keyName){
        return isKeyPressed(keyName, 1);
    }

    /**
     * keyNameのキーが押して離されたか 
     */
    boolean isKeyTyped(String keyName){
        if (!_keyBind.containsKey(keyName)) return false;
        return !keyPressed && (lastReleasedKey == _keyBind.get(keyName));
    }
}

class Stage {
    int STAGE_WIDTH = 10;
    int STAGE_HEIGHT = 20;
    int  HIDDEN_HEIGHT = 10;
    Coordinate DEFAULT_MINO_SPAWN_COORDINATE = new Coordinate(4, 19);
    /** 何もミノがない箇所の色 */
    int BG_COLOR = #b2b2b2;
    /** 現在の盤面を表す２次元配列。値はRGB色。 */
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
        addLine(STAGE_HEIGHT+HIDDEN_HEIGHT);
    }

    /**
     * ステージに一行追加するメソッド。
     */
    void addLine(int lineAmount){
        for(int j=0;j<lineAmount;j++){
            ArrayList<Integer> tempLine = new ArrayList<Integer>();
            for(int i=0;i<this.STAGE_WIDTH;i++){
                tempLine.add(BG_COLOR);
            }
            _stage.add(tempLine);
        }
    }

    /**
     * ステージの情報(現在動いているミノを含めて)返すメソッド. 左上が[0][0].
     * @return ArrayList<ArrayList<Integer>> ステージ情報
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
            tempStage.get(_currentMinoPosition.y+coordinate.y).set(_currentMinoPosition.x+coordinate.x,_currentMino.getColor());
        }
        ArrayList<ArrayList<Integer>> temp = new ArrayList<ArrayList<Integer>>(tempStage.subList(0, STAGE_HEIGHT));
        Collections.reverse(temp);
        return temp;
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
        addLine(fullLinesAmount);
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
            if(block == BG_COLOR){ return false; }
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
        return _stage.get(y).get(x) != BG_COLOR;
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
            _stage.get(_currentMinoPosition.y+coordinate.y).set(_currentMinoPosition.x+coordinate.x,_currentMino.getColor());
        }
    }
}

class TetrisMinoGenerator {
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
        list.add(new Mino(MinoTypes.CrazyIMino));
        list.add(new Mino(MinoTypes.CrazyOMino));
        list.add(new Mino(MinoTypes.CrazySMino));
        list.add(new Mino(MinoTypes.CrazyZMino));
        list.add(new Mino(MinoTypes.CrazyLMino));
        list.add(new Mino(MinoTypes.CrazyJMino));
        list.add(new Mino(MinoTypes.CrazyTMino));
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
    Empty,
    IMino,
    OMino,
    SMino,
    ZMino,
    LMino,
    TMino,
    JMino,
    CrazyIMino,
    CrazyOMino,
    CrazySMino,
    CrazyZMino,
    CrazyLMino,
    CrazyTMino,
    CrazyJMino,
}

class Mino{
    MinoTypes _type;
    int _colorCode;
    int _rotateIndex;
    Coordinate[][] _shapes;
    int[][] _displayArray2;

    Mino(MinoTypes type) {
        _rotateIndex = 0;
        _type = type;
        int[][][] shapeData;
        int[][] displayShapeData;
        switch(type){
            case IMino:
                this._colorCode = #00ffff;
                shapeData = new int[][][]{
                    {{-1,0},{0,0},{1,0},{2,0}},
                    {{0,-2},{0,-1},{0,0},{0,1}},
                    {{-2,0},{-1,0},{0,0},{1,0}},
                    {{0,-1},{0,0},{0,1},{0,2}}
                };
                displayShapeData = new int[][]{
                    {0, 1}, {1, 1}, {2, 1}, {3, 1}
                };
                break;
            case OMino:
                this._colorCode = #ffff00;
                shapeData = new int[][][]{
                    {{0,0},{1,0},{0,1},{1,1}},
                    {{0,0},{1,0},{0,1},{1,1}},
                    {{0,0},{1,0},{0,1},{1,1}},
                    {{0,0},{1,0},{0,1},{1,1}}
                };
                displayShapeData = new int[][]{
                    {1, 0}, {2, 0}, {1, 1}, {2, 1}
                };
                break;
            case SMino:
                this._colorCode = #00ff00;
                shapeData = new int[][][]{
                    {{-1,0},{0,0},{0,1},{1,1}},
                    {{1,-1},{1,0},{0,0},{0,1}},
                    {{-1,0},{0,0},{0,1},{1,1}},
                    {{1,-1},{1,0},{0,0},{0,1}}
                };
                displayShapeData = new int[][]{
                    {1, 0}, {2, 0}, {0, 1}, {1, 1}
                };
                break;
            case ZMino:
                this._colorCode = #ff0000;
                shapeData = new int[][][]{
                    {{-1,1},{0,1},{0,0},{1,0}},
                    {{-1,-1},{-1,0},{0,0},{0,1}},
                    {{-1,1},{0,1},{0,0},{1,0}},
                    {{-1,-1},{-1,0},{0,0},{0,1}}
                };
                displayShapeData = new int[][]{
                    {0, 0}, {1, 0}, {1, 1}, {2, 1}
                };
                break;
            case JMino:
                this._colorCode = #0000ff;
                shapeData = new int[][][]{
                    {{-1,1},{-1,0},{0,0},{1,0}},
                    {{0,-1},{0,0},{0,1},{1,1}},
                    {{1,-1},{-1,0},{0,0},{1,0}},
                    {{-1,-1},{0,-1},{0,0},{0,1}},
                };
                displayShapeData = new int[][]{
                    {0, 0}, {0, 1}, {1, 1}, {2, 1}
                };
                break;
            case LMino:
                this._colorCode = #e67928;
                shapeData = new int[][][]{
                    {{-1,0},{0,0},{1,0},{1,1}},
                    {{0,-1},{1,-1},{0,0},{0,1}},
                    {{-1,-1},{-1,0},{0,0},{1,0}},
                    {{0,-1},{0,0},{0,1},{-1,1}}
                };
                displayShapeData = new int[][]{
                    {2, 0}, {0, 1}, {1, 1}, {2, 1}
                };
                break;
            case TMino:
                this._colorCode = #800080;
                shapeData = new int[][][]{
                    {{-1,0},{0,0},{0,1},{1,0}},
                    {{0,-1},{1,0},{0,0},{0,1}},
                    {{-1,0},{0,0},{0,-1},{1,0}},
                    {{0,-1},{0,0},{0,1},{-1,0}}
                };
                displayShapeData = new int[][]{
                    {1, 0}, {0, 1}, {1, 1}, {2, 1}
                };
                break;
            case CrazyIMino:
                this._colorCode = #00ffff;
                shapeData = new int[][][]{
                    {{-1,0},{0,0},{1,0},{0,1},{0,2},{0,3},{-1,4},{0,4},{1,4}},
                    {{-2,1},{-2,2},{-2,3},{-1,2},{0,2},{1,2},{2,1},{2,2},{2,3}},
                    {{-1,0},{0,0},{1,0},{0,1},{0,2},{0,3},{-1,4},{0,4},{1,4}},
                    {{-2,1},{-2,2},{-2,3},{-1,2},{0,2},{1,2},{2,1},{2,2},{2,3}}
                };
                displayShapeData = new int[][]{
                    {0, 1}, {1, 1}, {2, 1}, {3, 1}
                };
                break;
            case CrazyOMino:
                this._colorCode = #ffff00;
                shapeData = new int[][][]{
                    {{0,0},{1,0},{-1,1},{2,1},{-1,2},{2,2},{-1,3},{2,3},{0,4},{1,4}},
                    {{-1,0},{0,0},{1,0},{-2,1},{2,1},{-2,2},{2,2},{-1,3},{0,3},{1,3}},
                    {{0,0},{1,0},{-1,1},{2,1},{-1,2},{2,2},{-1,3},{2,3},{0,4},{1,4}},
                    {{-1,0},{0,0},{1,0},{-2,1},{2,1},{-2,2},{2,2},{-1,3},{0,3},{1,3}}
                };
                displayShapeData = new int[][]{
                    {1, 0}, {2, 0}, {1, 1}, {2, 1}
                };
                break;
            case CrazySMino:
                this._colorCode = #00ff00;
                shapeData = new int[][][]{
                    {{-1,0},{0,0},{1,0},{2,1},{-1,2},{0,2},{1,2},{-2,3},{-1,4},{0,4},{1,4}},
                    {{-2,1},{-2,2},{-2,3},{-1,0},{0,1},{0,2},{0,3},{1,4},{2,1},{2,2},{2,3}},
                    {{-1,0},{0,0},{1,0},{2,1},{-1,2},{0,2},{1,2},{-2,3},{-1,4},{0,4},{1,4}},
                    {{-2,1},{-2,2},{-2,3},{-1,0},{0,1},{0,2},{0,3},{1,4},{2,1},{2,2},{2,3}}
                };
                displayShapeData = new int[][]{
                    {1, 0}, {2, 0}, {0, 1}, {1, 1}
                };
                break;
            case CrazyZMino:
                this._colorCode = #ff0000;
                shapeData = new int[][][]{
                    {{-1,4},{0,4},{1,4},{1,3},{0,2},{-1,1},{-1,0},{0,0},{1,0}},
                    {{-2,3},{-1,3},{2,3},{-2,2},{0,2},{2,2},{-2,1},{1,1},{2,1}},
                    {{-1,4},{0,4},{1,4},{1,3},{0,2},{-1,1},{-1,0},{0,0},{1,0}},
                    {{-2,3},{-1,3},{2,3},{-2,2},{0,2},{2,2},{-2,1},{1,1},{2,1}}
                };
                displayShapeData = new int[][]{
                    {0, 0}, {1, 0}, {1, 1}, {2, 1}
                };
                break;
            case CrazyJMino:
                this._colorCode = #0000ff;
                shapeData = new int[][][]{
                    {{1,4},{1,3},{1,2},{-1,1},{1,1},{-1,0},{0,0},{1,0}},
                    {{-2,3},{-1,3},{-2,2},{-2,1},{-1,1},{0,1},{1,1},{2,1}},
                    {{-1,4},{0,4},{1,4},{-1,3},{1,3},{-1,2},{-1,1},{-1,0}},
                    {{-2,3},{-1,3},{0,3},{1,3},{2,3},{2,2},{1,1},{2,1}}
                };
                displayShapeData = new int[][]{
                    {0, 0}, {0, 1}, {1, 1}, {2, 1}
                };
                break;
            case CrazyLMino:
                this._colorCode = #e67928;
                shapeData = new int[][][]{
                    {{-1,4},{-1,3},{-1,2},{-1,1},{-1,0},{0,0},{1,0}},
                    {{-2,3},{-1,3},{0,3},{1,3},{2,3},{-2,2},{-2,1}},
                    {{-1,4},{0,4},{1,4},{1,3},{1,2},{1,1},{1,0}},
                    {{2,3},{2,2},{-2,1},{-1,1},{0,1},{1,1},{2,1}}
                };
                displayShapeData = new int[][]{
                    {2, 0}, {0, 1}, {1, 1}, {2, 1}
                };
                break;
            case CrazyTMino:
                this._colorCode = #800080;
                shapeData = new int[][][]{
                    {{-1,4},{0,4},{1,4},{0,3},{0,2},{0,1},{0,0}},
                    {{2,3},{-2,2},{-1,2},{0,2},{1,2},{2,2},{2,1}},
                    {{0,4},{0,3},{0,2},{0,1},{-1,0},{0,0},{1,0}},
                    {{-2,3},{-2,2},{-1,2},{0,2},{1,2},{2,2},{-2,1}}
                };
                displayShapeData = new int[][]{
                    {1, 0}, {0, 1}, {1, 1}, {2, 1}
                };
                break;
            default:
                _colorCode = 0;
                shapeData = new int[][][]{};
                displayShapeData = new int[][]{};
                break;
        }
        _buildMino(shapeData, displayShapeData);
    }

    MinoTypes getType(){
        return _type;
    }

    void resetRotateIndex(){
        this._rotateIndex = 0;
    }

    void _buildMino(int[][][] data, int[][] displayData){
        _displayArray2 = new int[][]{{0, 0}, {0, 0}, {0, 0}, {0, 0}};
        _shapes = new Coordinate[][]{};
        if (_type == MinoTypes.Empty) return;

        int blockSize = data[0].length;
        Coordinate[][] shapes = new Coordinate[4][blockSize];
        for(int i=0; i<4; i++){
            for(int j=0; j<blockSize; j++){
                shapes[i][j] = new Coordinate(data[i][j][0], data[i][j][1]);
            }
        }
        this._shapes = shapes;

        for (int i=0; i<4; i++){
            int[] temp = displayData[i];
            _displayArray2[temp[0]][temp[1]] = 1;
        }
    }

    /** 現在の回転された形状を返す */
    Coordinate[] getCurrentShape(){
        if (_type == MinoTypes.Empty) return new Coordinate[]{};
        return _shapes[_rotateIndex];
    }

    /** HOLDやNEXTの表示用２次元配列を返す。左上を(0, 0)とした4*2の空間。ブロックがある箇所は1, 何もない箇所は0。 */
    int[][] getDisplayArray2(){
        return _displayArray2;
    }

    Coordinate[] getLeftRotatedShape(boolean leftRotate){
        if (_type == MinoTypes.Empty) return new Coordinate[]{};
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

    int getColor(){
        return this._colorCode;
    }
}
