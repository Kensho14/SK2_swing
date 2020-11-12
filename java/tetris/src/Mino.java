public class Mino{
    int _colorID;
    int _rotateIndex;
    Coordinate[][] _shapes;

    enum MinoTypes {
        IMino,
        OMino,
        SMino,
        ZMino,
        LMino,
        TMino,
        JMino
    }

    Mino(MinoTypes type) {
        _rotateIndex = 0;
        switch(type){
            case IMino:
                this._colorID = 1;
                _buildMino(new int[][][]
                        {{{-1,0},{0,0},{1,0},{2,0}},
                                {{0,-2},{0,-1},{0,0},{0,1}},
                                {{-2,0},{-1,0},{0,0},{1,0}},
                                {{0,-1},{0,0},{0,1},{0,2}}}
                );
                break;
            case OMino:
                this._colorID = 2;
                _buildMino(new int[][][]
                        {{{-1,-1},{-1,0},{0,-1},{0,0}},
                                {{-1,-1},{-1,0},{0,-1},{0,0}},
                                {{-1,-1},{-1,0},{0,-1},{0,0}},
                                {{-1,-1},{-1,0},{0,-1},{0,0}}}
                );
                break;
            case SMino:
                this._colorID = 3;
                _buildMino(new int[][][]
                        {{{-1,0},{0,0},{0,1},{1,1}},
                                {{1,-1},{1,0},{0,0},{0,1}},
                                {{-1,0},{0,0},{0,1},{1,1}},
                                {{1,-1},{1,0},{0,0},{0,1}}}
                );
                break;
            case ZMino:
                this._colorID = 4;
                _buildMino(new int[][][]
                        {{{-1,1},{0,1},{0,0},{1,0}},
                                {{-1,-1},{-1,0},{0,0},{0,1}},
                                {{-1,1},{0,1},{0,0},{1,0}},
                                {{-1,-1},{-1,0},{0,0},{0,1}}}
                );
                break;
            case LMino:
                this._colorID = 5;
                _buildMino(new int[][][]
                        {{{0,-1},{1,-1},{0,0},{0,1}},
                                {{-1,-1},{-1,0},{0,0},{1,0}},
                                {{0,-1},{0,0},{0,1},{-1,1}},
                                {{-1,0},{0,0},{1,0},{1,1}}}
                );
                break;
            case TMino:
                this._colorID = 6;
                _buildMino(new int[][][]
                        {{{-1,0},{0,0},{0,1},{1,0}},
                                {{0,-1},{-1,0},{0,0},{0,1}},
                                {{-1,0},{0,0},{0,1},{1,0}},
                                {{0,-1},{0,0},{0,1},{1,0}}}
                );
                break;
            case JMino:
                this._colorID = 7;
                _buildMino(new int[][][]
                        {{{-1,-1},{0,-1},{0,0},{0,1}},
                                {{-1,1},{-1,0},{0,0},{1,0}},
                                {{0,-1},{0,0},{0,1},{1,1}},
                                {{1,-1},{-1,0},{0,0},{1,0}}}
                );
                break;
            default:
                break;
        }
    }

    void resetRotateIndex(){
        this._rotateIndex = 0;
    }

    void _buildMino(int[][][] data){
        int blockSize = data[0].length;
        Coordinate[][] shapes = new Coordinate[4][blockSize];
        for(int i=0; i<4; i++){
            for(int j=0; j<blockSize; j++){
                shapes[i][j] = new Coordinate(data[i][j][0], data[i][j][1]);
            }
        }
        this._shapes = shapes;
    }

    Coordinate[] getCurrentShape(){
        return _shapes[_rotateIndex];
    }

    Coordinate[] getLeftRotatedShape(boolean leftRotate){
        int temp = _rotateIndex;
        if (leftRotate) temp--;
        else temp++;
        if (temp < 0) temp = 3;
        if (temp > 3) temp = 0;
        return _shapes[temp];
    }

    void rotate(boolean leftRotate){
        if (leftRotate) _rotateIndex--;
        else _rotateIndex++;
        if (_rotateIndex < 0) _rotateIndex = 3;
        if (_rotateIndex > 3) _rotateIndex = 0;
    }

    int getColorID(){
        return this._colorID;
    }
}
