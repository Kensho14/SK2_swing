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