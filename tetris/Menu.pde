class SMenu extends Scene {
    CButton _btnStart;
    CButton _btnRanking;
    CButton _btnend;

    SMenu(){
        super();
    }

    @Override
    void setup(){
        super.setup();
        background(255, 255, 0);
        _btnStart = new CButton(100, 50, 100, 50, "Start");
        addComponent(_btnStart);
        _btnRanking = new CButton(500, 50, 150, 50, "Ranking");
        addComponent(_btnRanking);
        _btnend = new CButton(900, 50, 100, 50, "End");
        addComponent(_btnend);
    }

    @Override
    void draw(){
        super.draw();
        if (_btnStart.isClicked()){
            app.changeScene(new SPlay());
            println("Start pressed!");
        }
        if (_btnRanking.isClicked()){
            app.changeScene(new SRanking());
            println("Ranking pressed!");
        }
        if (_btnend.isClicked()){
            System.exit(0);
        }
    }
}
