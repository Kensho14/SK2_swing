class Tetris extends Application {
    Tetris() {
        super();
    }

    @Override
    void setup(){
        super.setup();
        changeScene(new PlayScene());
    }
}

class PlayScene extends Scene{
    PlayScene(){
        TetrisController controller = new TetrisController();
    }

    @Override
    draw(){
        controller.draw();
    }
}

class TetrisController{
    int _WIDTH = 10;
    int _HEIGHT = 20;
    Stage _stage = new Stage();

    TetrisController(){
        
    }
}

class stage{
    ArrayList<Arraylist<Block>> _stage = new ArrayList<>();

    setStageSize(int width,int height){
        for(int i=0;i<height;i++){
            _stage.add(new Arraylist<block>);
            for(int j=0;j<width;j++){
                _stage.get(i).add(new Block())
            }
        }
    }

    boolean isLineFull(ArrayList _line){
        for(mino:line){
            if(mino=0){ return false; }
        }
        return true;
    }

    checkLineFull(){

    }
}

class Block extends Components{
    String _state = "null";

    void setBlockColor(String color){
        _state = color;
    }

    String getState(){
        return _state;
    }
}
    
class TetrisMinoGenerator{
    ArrayList<mino> minoList = new ArrayList<>();
    minoList.length
}
