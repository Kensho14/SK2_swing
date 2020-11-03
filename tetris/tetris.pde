
/**
 * アプリケーション毎に一つ。Sceneの管理等を行う。これを継承して具体的な実装を行う.
 */
class Application {
    Scene _currentScene = null;

    Application(){
        setup();
    }

    void setup() {}

    /** Sceneを変更する */
    void changeScene(Scene s){
        background(51);
        s.setup();
        _currentScene = s;
    }

    void draw() {
        if (_currentScene != null) {
            _currentScene.draw();
        }
    }
}

/**
 * メニュー画面等，画面毎に一つ。構成部品であるComponentの配置，管理をここで行う。具体的なシーンはこれを継承して作成する.
 */
class Scene {
    ArrayList<Component> _components = new ArrayList<Component>();

    Scene() {}

    /** ApplicationでchangeSceneが呼ばれたタイミングで実行される。 */
    void setup() {}

    void addComponent(Component c){
        c.setup();
        _components.add(c);
    }

    void draw() {
        for (Component c : _components) {
            if (c.isEnabled()) c.draw();
        }
    }
}

/**
 * 構成部品。これを継承して具体的な実装を行う。
 */
class Component {
    /** falseだとSceneからdraw()を呼ばれない */
    boolean _enabled = true;
    float _x;
    float _y;
    float _w;
    float _h;
    /** Component上にマウスカーソルがあるかどうか */
    boolean _onMouse;
    ArrayList<Component> _childComponents = new ArrayList<Component>();

    Component(float x, float y, float w, float h) {
        _x = x;
        _y = y;
        _w = w;
        _h = h;
    }

    /** addComponentされたタイミングで呼ばれる */
    void setup() {}

    void draw() {
        _onMouse = (_x <= mouseX && mouseX <= _x+_w && _y <= mouseY && mouseY <= _y+_h);
        for (Component c : _childComponents){
            if (c.isEnabled()) c.draw();
        }
    }

    boolean isEnabled() {
        return _enabled;
    }
    void setEnabled(boolean enable){
        _enabled = enable;
    }

    void addChildComponent(Component c){
        c.setup();
        _childComponents.add(c);
    }
}

class CButton extends Component {
    String _text;

    CButton(float x, float y, float w, float h, String t){
        super(x, y, w, h);
        _text = t;
    }

    @Override
    void draw(){
        super.draw();

        fill(0, 127, 255);
        rect(_x, _y, _w, _h, 7);
        fill(255);
        textAlign(CENTER, CENTER);
        textSize(_h-12);
        text(_text, _x, _y, _w, _h);
        textAlign(RIGHT, TOP);
    }

    boolean isPressed() {
        return mousePressed && _onMouse;
    }

    boolean isClicked() {
        return mouseClicked && _onMouse;
    }
}

class Tetris extends Application {
    Tetris() {
        super();
    }

    @Override
    void setup(){
        super.setup();
        changeScene(new SMenu());
    }
}

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
