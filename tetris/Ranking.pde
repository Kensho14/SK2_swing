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