class Tetris extends Application {
    long appElapsedFrames;

    Tetris() {
        super();
    }

    @Override
    void setup(){
        appElapsedFrames = 0;
        super.setup();
        // addRanking(500, 500);
        changeScene(new SMenu());
    }

    @Override
    void draw(){
        appElapsedFrames++;
        super.draw();
    }
}

boolean _lastMousePressed = false;
/** 前フレームでマウスボタンが押されていて，今フレームで離された場合にtrueが格納される。 */
boolean mouseClicked = false;
char lastReleasedKey;
char lastTypedKey;

Application app;

void setup() {
    size(1280, 720);

    app = new Tetris();
}

void draw() {
    mouseClicked = !mousePressed && _lastMousePressed;
    _lastMousePressed = mousePressed;
    
    app.draw();

    lastReleasedKey = '\u0000';
    lastTypedKey = '\u0000';
}

void keyReleased() {
    lastReleasedKey = key;
}

void keyTyped() {
    lastTypedKey = key;
}

/** 秒数をmm:ss形式にして返す */
String formatTime(int seconds){
    int minutes = seconds / 60;
    return String.format("%02d:%02d", minutes, seconds%60);
}