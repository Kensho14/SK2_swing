class SMenu extends Scene {
    CButton _btnStart;

    SMenu(){
        super();
    }

    @Override
    void setup(){
        super.setup();
        background(255, 255, 0);
        _btnStart = new CButton(50, 50, 100, 50, "Start");
        addComponent(_btnStart);
    }

    @Override
    void draw(){
        super.draw();
        if (_btnStart.isClicked()){
            println("Start pressed!");
        }
    }
}