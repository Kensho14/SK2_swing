class SMenu extends Scene {
    CButton _btnStart;
    CButton _btnRanking;
    CButton _btnend;
    PFont tetoris;
    
    SMenu(){
        super();
    }

    @Override
    void setup(){
        super.setup();
        background(211, 211, 211);
        _btnStart = new CButton(500, 400, 250, 70, "Start");
        addComponent(_btnStart);
        _btnRanking = new CButton(500, 500, 250, 70, "Ranking");
        addComponent(_btnRanking);
        _btnend = new CButton(500, 600, 250, 70, "End");
        addComponent(_btnend);
        
        //フォントを読み込む
        tetoris = loadFont("Arial-BoldMT-48.vlw");
    }

    @Override
    void draw(){
        super.draw();
        if (_btnStart.isClicked()){
            app.changeScene(new SPlay());
            println("Start pressed!");
        }
        if (_btnRanking.isClicked()){
            app.changeScene(new SRanking(false));
            println("Ranking pressed!");
        }
        if (_btnend.isClicked()){
            System.exit(0);
        }
        
        //ゲーム名
        textFont(tetoris, 200);
        int n = 6;
        for(int i = 0; i < n; i++){
            if(i == 0){
                fill(#FF0303);
                text("T", 300, 100);
            }else if(i == 1){
                fill(#2FD122);
                text("E", 410, 100);
            }else if(i == 2){
                fill(#FCAD00);
                text("T", 520, 100);
            }else if(i == 3){
                fill(#9B00CB);
                text("R", 630, 100);
            }else if(i == 4){
                fill(#03D7FF);
                text("I", 770, 100);
            }else if(i == 5){
                fill(#FFF703);
                text("S", 800, 100);
            }
        }
    }
}