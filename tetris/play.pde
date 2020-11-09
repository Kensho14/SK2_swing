import java.util.ArrayList;
import java.util.Collections;

class CTetrisEnv{
    TetrisController tetris = new TetrisController();

    void draw(){
        tetris.draw();
    }
}

class SPlay extends Scene{
    CTetrisEnv tetrisEnv = new CTetrisEnv();

    void draw(){
        tetrisEnv.draw();
    }
}

class TetrisController{
    int _WIDTH = 10;
    int _HEIGHT = 20;
    Stage _stage = new Stage();

    TetrisController(){
        _stage.init(_WIDTH,_HEIGHT);
    }
    void draw(){

    }

}

class Stage extends Component{
    Coordinate movingMinoCoordinate;
    ArrayList<ArrayList<Integer>> _stage;
    int width;
    int height;

    void init(int width,int height){
        _stage = new ArrayList<ArrayList<Integer>>();
        _setStageSize(width,height);
    }

    void _setStageSize(int width,int height){
        this.width = width;
        this.height = height;
        for(int i=0;i<height;i++){
            addLine();
        }
    }

    void addLine(){
        ArrayList<Integer> tempLine = new ArrayList<>();
        for(int i=0;i<this.width;i++){
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

    void checkLinesFull(){
        for(int i=0;i<_stage.size();i++){
            ArrayList<Integer> targetLine = _stage.get(i);
            if(isLineFull(targetLine)){
                _removeLine(i);
                _addLines(1);
            }
        }
    }

    void _removeLine(int lineNum){
        _stage.remove(lineNum);
    }

    void _addLines(int amount){
        for(int i=0;i<amount;i++){
            addLine();
        }
    }

    @override
    void draw(){

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
    Coordinate[][] coordinate;
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