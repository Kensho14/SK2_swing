import java.util.Collections;

class SPlay extends Scene{
    CTetrisEnv _tetrisEnv;

    SPlay(){
        super();
    }

    @Override
    void setup(){
        super.setup();
        _tetrisEnv = new CTetrisEnv();
        addComponent(CTetrisEnv);
    }

    void draw(){
        super.draw();
    }
}

    color[] MINO_COLORS = new int[7] { new color(0, 0, 0), new color(0, 0, 0), new color(0, 0, 0), new color(0, 0, 0), new color(0, 0, 0), new color(0, 0, 0), new color(0, 0, 0) };

class CTetrisEnv extends Component{
    TetrisCore tetris;

    CTetrisEnv(){
        super();
        tetris = new TetrisCore();
    }

    @Override
    void draw(){
        super.draw();
        // ここで描画する
        tetris.update();
    }
}

class TetrisCore{
    boolean holdFlag;
    int _DOWN_INTERVAL = 60;
    int _WIDTH = 10;
    int _HEIGHT = 20;
    int _movingMinoTickCount;
    Stage _stage;
    TetrisMinoGenerator _minoGenerator;
    Input _input;
    Mino _hold;
    int _score;

    TetrisCore(){
        _minoGenerator  = new TetrisMinoGenerator();
        _stage = new Stage();
        _hold = null;
        _stage.init(_WIDTH,_HEIGHT);
    }

    void update(){
        //毎フレーム呼び出される
        if(_stage.getCurrentMino()==null){
            _stage.setCurrentMino(_minoGenerator.takeWaitingMino(0));
            _stage.minoPositionInit();
            this._movingMinoTickCount = 0;
        }
        /**
         * isKeyClicked(String);
         * 前フレームで押されておらず、今のフレームで押されている場合true, それ以外falseを期待。
         */
        if(_input.isKeyClicked("left")){
            _stage.moveLeft();
        }
        if(_input.isKeyClicked("right")){
            _stage.moveRight();
        }
        if(_input.isKeyClicked("drop")){
            _stage.drop();
        }
        if(_input.isKeyClicked("hardDrop")){
            _stage.hardDrop();
            _stage.placeMino();
            if(isOverFromStage){
                gameOver();
            }
            _stage.setCurrentMino(_minoGenerator.takeWaitingMino(0));
            _stage.minoPositionInit();
            _movingMinoTickCount = 0;
        }
        if(_input.isKeyClicked("leftRotate")){
            _stage._currentMino.rotate(false);
        }
        if(_input.isKeyClicked("rightRotate")){
            _stage._currentMino.rotate(true);
        }
        if(_input.isKeyClicked("hold")){
            if(!holdFlag){
                swap();
            }
        }
        //ここから自然に落ちる処理
        _movingMinoTickCount++;
        if(_movingMinoTickCount<=_DOWN_INTERVAL){
            if(!_stage.drop()){
                _stage.placeMino();
                if(isOverFromStage){
                    gameOver();
                }
                _stage.setCurrentMino(_minoGenerator.takeWaitingMino(0));
                _stage.minoPositionInit();
                _movingMinoTickCount = 0;
            }
        }

        void gameOver(){
            //ゲームオーバーの処理
            //秒数も実装するの？
            //addRanking(_score,100);
            //app.changeScene(new SRanking());
        }
    }

    void addScore(int deleteLine){
        _score += 10*Math.pow(2,deleteLine-1);
    }

    void swap(){
        if(_hold==null){
            _hold = _stage.getCurrentMino();
            _stage.setCurrentMino(_minoGenerator.takeWaitingMino(0));
        } else{
            Mino temp = this._hold;
            _hold = _stage.getCurrentMino();
            _stage.setCurrentMino(temp);
        }
        _stage.minoPositionInit();
    }
    /**
     * 最終的な計算された盤面の２次元配列を返す
     * @return int[][] 盤面
     */
    int[][] getStage(){
        
    }
}

/*class Input{
    HashMap<Character,Boolean> _states;
    char pressedKey;
    char[] keyset1 = {'w','d','s','a','g','h'};

    Input(int keySetNumber){
        _states = new HashMap<>();
        init(keyset1);
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
}*/

class Stage{
    Coordinate DEFAULT_COORDINATE = new Coordinate(4,19);
    Coordinate _currentMinoPosition;
    //boolean _minoMovingFlag;
    Mino _currentMino;
    ArrayList<ArrayList<Integer>> _stage;
    int stageWidth;
    int stageHeight;
    /**
     * 本来のステージの上に隠れている部分のステージの高さ指定
     */
    int HIDDEN_HEIGHT = 4;

    Stage(){
    }

    boolean isOverFromStage(){
        return _stage._currentMino().y => HEIGHT;
    }

    void minoPositionInit(){
        this._currentMinoPosition = DEFAULT_COORDINATE;
        this._currentMino.resetRotateIndex();
    }

    void init(int stageWidth,int stageHeight){
        _stage = new ArrayList<ArrayList<Integer>>();
        //_minoMovingFlag = false;
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
            tempLine.add(0);
        }
        _stage.add(tempLine);
    }

    Mino getCurrentMino(){
        return this._currentMino;
    }

    void setCurrentMino(Mino mino){
        this._currentMino = mino;
    }

    boolean isLineFull(ArrayList<Integer> _line){
        for(Integer block:_line){
            if(block==0){ return false; }
        }
        return true;
    }

    /*boolean isMinoMoving(){
        return this._minoMovingFlag;
    }*/

    void generateMino(Mino mino){
        this._currentMino = mino;
    }

    int checkLinesFull(){
        int fullLinesAmount = 0;
        for(int i=_stage.size()-1;i<=0;i--){
            ArrayList<Integer> targetLine = _stage.get(i);
            if(isLineFull(targetLine)){
                _removeLine(i);//TODO: iterator使う
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

    boolean isBlocksFilled(int x,int y){
        for(Coordinate coordinate:_currentMino.getCurrentShape()){
            if(isBlockFilled(_currentMinoPosition.x+coordinate.x + x, _currentMinoPosition.y+coordinate.y + y)){
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

    void placeMino(){
        for(Coordinate coordinate:_currentMino.getCurrentShape()){
            _stage.get(_currentMinoPosition.x+coordinate.y).set(_currentMinoPosition.y+coordinate.y,_currentMino.getColorID());
        }
        //_minoMovingFlag = false;
    }

    boolean isLanding(){
        return isBlocksFilled(0, -1);
    }
}

class TetrisMinoGenerator{
    ArrayList<Mino> _waitingMinoList;

    TetrisMinoGenerator(){
        _waitingMinoList = new ArrayList<Mino>();
        _generate();
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

    /** Next用 */
    Mino getWaitingMino(int i){
        return _waitingMinoList.get(i);
    }

    /** ひとつ取り出す */
    Mino takeWaitingMino(int i){
        Mino temp = _waitingMinoList.get(i);
        _waitingMinoList.remove(i);
        if(_waitingMinoList.size()<10){
            _generate();
        }
        return temp;
    }
}

class Mino{
    int _colorID;
    int _rotateIndex;
    Coordinate[][] _shapes;

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
                    {{{0,-1},{1,-1},{0,0},{1,0}},
                    {{-1,-1},{-1,0},{0,0},{1,0}},
                    {{0,-1},{0,0},{0,1},{-1,1}},
                    {{-1,0},{0,0},{1,0},{1,1}}}
                );
                break;
            case TMino:
                this._colorID = 6;
                _buildMino(new int[][][]
                    {{{-1,0},{0,0},{0,1},{-1,0}},
                    {{0,-1},{-1,0},{0,0},{0,1}},
                    {{-1,0},{0,0},{0,1},{1,0}},
                    {{0,-1},{0,0},{0,1},{1,0}}}
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

class Coordinate{
    int x;
    int y;

    Coordinate(){
        this.x = 0;
        this.y = 0;
    }

    Coordinate(int x, int y){
        this.x = x;
        this.y = y;
    }
}
