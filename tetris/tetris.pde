import java.io.File;
import java.time.Duration;
import java.util.Comparator;
import java.util.Collections;

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
        textSize(_h-15);
        text(_text, _x, _y, _w, _h);
        textAlign(LEFT, TOP);
    }

    boolean isPressed() {
        return mousePressed && _onMouse;
    }

    boolean isClicked() {
        return mouseClicked && _onMouse;
    }
}

class CRankingTable extends Component {
    class RankingEntry {
        int point;
        Duration aliveTime;

        RankingEntry(int point, Duration aliveTime){
            this.point = point;
            this.aliveTime = aliveTime;
        }
    }
    /** 降順になるようにRankingEntryを比較する */
    class RankingEntryComparator implements Comparator<RankingEntry> {
        @Override
        public int compare(RankingEntry e1, RankingEntry e2) {
            if (e1.point != e2.point){
                return e1.point < e2.point ? 1 : -1;
            }else if (!e1.aliveTime.equals(e2.aliveTime)){
                return e2.aliveTime.compareTo(e1.aliveTime);
            }else{
                return 0;
            }
        }
    }

    ArrayList<RankingEntry> _rankingData;
    int TEXT_SIZE = 32;

    CRankingTable(float x, float y, float w, float h){
        super(x, y, w, h);
    }

    void load(String path){
        // if (!new File(path).exists()){
        //     println(path + " is not exits.");
        //     _rankingData = new ArrayList<RankingEntry>();
        //     return;
        // }
        String[] lines = loadStrings(path);
        for (String line : lines){
            String[] temp = line.split(",");
            int point = Integer.parseInt(temp[0]);
            Duration aliveTime = Duration.ofSeconds(Long.parseLong(temp[1]));
            _rankingData.add(new RankingEntry(point, aliveTime));
            println(line);
        }
        Collections.sort(_rankingData, new RankingEntryComparator());
    }

    @Override
    void setup(){
        super.setup();
        _rankingData = new ArrayList<RankingEntry>();
        // String fpath = new File("./ranking.csv").getAbsolutePath();
        load("ranking.csv");
    }

    @Override
    void draw(){
        super.draw();
        textSize(TEXT_SIZE);
        textAlign(LEFT, CENTER);
        fill(0, 102, 153);
        text("Rank Point AliveTime", _x, _y);
        for (int i=0; (TEXT_SIZE*i < _w-TEXT_SIZE) && (i < _rankingData.size()); i++){
            RankingEntry e = _rankingData.get(i);
            text(i+1 + ". " + e.point + " " + e.aliveTime.toString(), _x, _y+(TEXT_SIZE*(i+1)));
        }
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

class SRanking extends Scene {
    boolean _showRetry;

    CRankingTable _table;

    SRanking(boolean showRetry){
        super();
        _showRetry = showRetry;
    }

    @Override
    void setup(){
        super.setup();
        _table = new CRankingTable(100, 50, 200, 200);
        addComponent(_table);
    }

    @Override
    void draw(){
        background(255, 255, 0);
        super.draw();
    }
}

class Tetris extends Application {
    Tetris() {
        super();
    }

    @Override
    void setup(){
        super.setup();
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

void saveRanking(){

}