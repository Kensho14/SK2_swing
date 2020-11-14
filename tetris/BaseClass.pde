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
    ArrayList<Component> _components;

    Scene() {
        _components = new ArrayList<Component>();
    }

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
    ArrayList<Component> _childComponents;

    Component(float x, float y, float w, float h) {
        _childComponents = new ArrayList<Component>();
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