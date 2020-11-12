import java.util.ArrayList;
import java.util.Iterator;

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

    void _setStageSize(){
        for(int i=0;i<STAGE_HEIGHT+HIDDEN_HEIGHT;i++){
            addLine();
        }
    }
    void addLine(){
        ArrayList<Integer> tempLine = new ArrayList<Integer>();
        for(int i=0;i<this.STAGE_WIDTH;i++){
            tempLine.add(0);
        }
        _stage.add(tempLine);
    }

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

    boolean isLineFull(ArrayList<Integer> _line){
        for(Integer block:_line){
            if(block==0){ return false; }
        }
        return true;
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
        if(x<0||y<0||x>=this.STAGE_WIDTH||y>=this.STAGE_HEIGHT+HIDDEN_HEIGHT){
            return true;
        }
        return _stage.get(y).get(x)!=0;
    }

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
