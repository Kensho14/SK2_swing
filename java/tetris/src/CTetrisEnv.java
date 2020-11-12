import java.util.ArrayList;
import java.util.Scanner;

public class CTetrisEnv {
    Scanner scanner;
    TetrisCore tetris;

    CTetrisEnv() {
        scanner = new Scanner(System.in);
        tetris = new TetrisCore();
    }

    void draw() {
        String temp2 = scanner.nextLine();
        switch (temp2) {
            case "a" -> tetris.moveLeft();
            case "d" -> tetris.moveRight();
            case "s" -> tetris.drop();
            case "g" -> tetris.leftRotate();
            case "h" -> tetris.rightRotate();
            case "w" -> tetris.hardDrop();
            case "e" -> tetris.hold();
        }
        tetris.update();
        System.out.println(tetris._movingMinoTickCount);
        /*if (temp % 3 == 0) {
            if (!tetris._stage.drop()) {
                tetris.placeMino();
            }
        }*/
        printStage(tetris._stage.getStage());
        System.out.println(tetris.getScore());
    }

    void printStage(ArrayList<ArrayList<Integer>> stage) {
        for (int i = 0; i < stage.size(); i++) {
            System.out.print(stage.size() - i + 9 + ": ");
            for (Integer j : stage.get(stage.size() - i - 1)) {
                System.out.print(j);
            }
            System.out.print("\n");
        }
    }
}
