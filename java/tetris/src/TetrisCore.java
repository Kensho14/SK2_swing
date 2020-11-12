public class TetrisCore {
    int _DOWN_INTERVAL = 4;
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

    void addScore(int deleteLine){
        if(deleteLine>=1) _score += 10*Math.pow(2,deleteLine-1);
    }

    int getScore(){
        return this._score;
    }

    void update(){
        _movingMinoTickCount++;
        if(_movingMinoTickCount>=_DOWN_INTERVAL){
            if(!drop()){
                placeMino();
            }
        }
    }

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

    void hold(){
        if(!_holdFlag){
            _swap();
            this._holdFlag = true;
        }
    }

    void placeMino(){
        _stage.placeMino();
        _holdFlag = false;
        if (this._stage.isOverFromStage()) gameOver();
        this.addScore(this._stage.checkLinesFull());
        this._stage.minoInit(this._minoGenerator.takeWaitingMino(0));
        this._movingMinoTickCount = 0;
    }
}
