class Tetris extends Application {
    Tetris() {
        super();
    }

    @Override
    void setup(){
        super.setup();
        // addRanking(500, 500);
        changeScene(new SRanking(true));
    }
}

boolean _lastMousePressed = false;
/** 前フレームでマウスボタンが押されていて，今フレームで離された場合にtrueが格納される。 */
boolean mouseClicked = false;

Application app;

void setup() {
    size(1280, 720);

    app = new Tetris();
}

void draw() {
    mouseClicked = !mousePressed && _lastMousePressed;
    _lastMousePressed = mousePressed;

    app.draw();
}
