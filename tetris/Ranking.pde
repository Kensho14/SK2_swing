import java.util.Comparator;
import java.util.Collections;
import java.util.Arrays;

/** ランキングをファイルから読み込んで表示するコンポーネント. */
class CRankingTable extends Component {
    class RankingEntry {
        int point;
        int aliveTime;

        RankingEntry(int point, int aliveTime){
            this.point = point;
            this.aliveTime = aliveTime;
        }
    }
    /** 降順になるようにRankingEntryを比較する. ポイント，生存時間の順に高いやつから並ぶ. */
    class RankingEntryComparator implements Comparator<RankingEntry> {
        @Override
        public int compare(RankingEntry e1, RankingEntry e2) {
            if (e1.point != e2.point){
                return e1.point < e2.point ? 1 : -1;
            }else if (e1.aliveTime != e2.aliveTime){
                return e1.aliveTime < e2.aliveTime ? 1 : -1;
            }else{
                return 0;
            }
        }
    }

    ArrayList<RankingEntry> _rankingData;
    int _columnSize = 50;

    int _textSize;
    float _pointX;
    float _timeX;

    /** 
     * 1列のサイズを指定することで，コンポーネントの高さに入り切るだけ表示する.
     * @param columnSize 列のサイズ
     */
    CRankingTable(float x, float y, float w, float h, int columnSize){
        super(x, y, w, h);
        _columnSize = columnSize;
        _textSize = _columnSize - 10;
        _pointX = x + (_textSize/2)*3;
        _timeX = (x+w) - (_textSize/2)*5;
    }

    /**
     * ランキングデータをファイルから読み込む. 
     * @param path <project>/data を基準にパスを指定。
     */
    void load(String path){
        String[] lines = loadStrings(path);
        if (lines == null){
            println("Not exist : "+path);
            _rankingData = new ArrayList<RankingEntry>();
            return;
        }
        for (String line : lines){
            String[] temp = line.split(",");
            if (temp.length != 2) continue;
            int point = Integer.parseInt(temp[0]);
            int aliveTime = Integer.parseInt(temp[1]);
            _rankingData.add(new RankingEntry(point, aliveTime));
            println(line);
        }
        Collections.sort(_rankingData, new RankingEntryComparator());
    }

    /** 秒数をmm:ss形式にして返す */
    String formatTime(int seconds){
        int minutes = seconds / 60;
        return String.format("%02d:%02d", minutes, seconds%60);
    }

    @Override
    void setup(){
        super.setup();
        _rankingData = new ArrayList<RankingEntry>();
        load("../ranking.dat");
    }

    @Override
    void draw(){
        super.draw();
        textSize(_textSize);
        fill(0, 0, 0);
        textAlign(CENTER, CENTER);
        text("Point", _pointX, _y, _timeX-_pointX, _columnSize);
        // textAlign(RIGHT, CENTER);
        text("Time", _timeX, _y, _w-_timeX, _columnSize);
        for (int i=0; (_columnSize*i < _w-_columnSize) && (i < _rankingData.size()); i++){
            RankingEntry e = _rankingData.get(i);
            float y = _y + (_columnSize*(i+1));
            textAlign(LEFT, CENTER);
            text(i+1 + ".", _x, y, _pointX, _columnSize);
            textAlign(CENTER, CENTER);
            text(e.point + "", _pointX, y, _timeX-_pointX, _columnSize);
            textAlign(RIGHT, CENTER);
            text(formatTime(e.aliveTime), _timeX, y, _w-_timeX, _columnSize);
        }
    }
}

class SRanking extends Scene {
    boolean _showRetry;

    CRankingTable _table;
    CButton _retryBtn;
    CButton _menuBtn;

    SRanking(boolean showRetry){
        super();
        _showRetry = showRetry;
    }

    @Override
    void setup(){
        super.setup();
        _table = new CRankingTable(270, 80, 740, 200, 52);
        addComponent(_table);
        _retryBtn = new CButton(940, 600, 140, 50, "Retry");
        if (_showRetry) addComponent(_retryBtn);
        _menuBtn = new CButton(1090, 600, 140, 50, "Menu");
        addComponent(_menuBtn);
    }

    @Override
    void draw(){
        background(211, 211, 211);
        super.draw();
        if (_retryBtn.isClicked()){
            app.changeScene(new SPlay());
            println("changeScene Play Scene.");
        }
        if (_menuBtn.isClicked()){
            app.changeScene(new SMenu());
            println("changeScene Menu Scene.");
        }
    }
}

/** 
 * ランキングに追加する. インナークラスにstaticメソッドは書けないので，ここに.
 * @param point スコアポイント
 * @param aliveSeconds 生存時間
 */
void addRanking(int point, int aliveSeconds){
    String PATH = "ranking.dat";
    String[] temp = loadStrings("../"+PATH);
    if (temp == null){
        temp = new String[]{};
    }
    ArrayList<String> lines = new ArrayList<String>(Arrays.asList(temp));
    lines.add(String.format("%d,%d", point, aliveSeconds));
    saveStrings(PATH, lines.toArray(new String[1]));
}