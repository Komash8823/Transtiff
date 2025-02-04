import processing.serial.*;
import controlP5.*; // GUIのライブラリ

ControlP5 cp5;
ControlP5 btn;
ControlP5 cp5tf;
Serial port;

Toggle toggle;
String StringCurrentTemperature;
float FloatCurrentTemperature;
int val = 0; // Arduinoに送信するデータ
String data_string; //シリアルで受け取る全文字列
String[] arr_data;

// ボタン用の変数（チェックボックス風）
boolean forwardRotation; // 順回転用ボタン
boolean reverseRotation; // 逆回転用ボタン
boolean oneRotation; // 1回転ボタン
boolean Rotation0; // 回転量0/4ボタン
boolean Rotation1; // 回転量1/4ボタン
boolean Rotation2; // 回転量2/4ボタン
boolean Rotation3; // 回転量3/4ボタン
boolean Rotation4; // 回転量4/4ボタン

float pos;

int acc1,acc2;
float acc3;   
float Max = 10, max=0;       
float X;             
float Spx;        
float Acx; 
float[] numberArray = {};

void setup(){
  port = new Serial(this, "COM6", 9600); // ポート設定
  background( #2f4f4f ); // 背景色の設定 (今回はdarkslategray)
  size(1200, 600); // ウィンドウサイズ
  cp5 = new ControlP5(this); // ControlP5クラスのインスタンス作成
  
  // 以下ボタンの設定
  // 順回転用のボタン
  cp5.addToggle("forwardRotation") // addToggleメソッド
     .setLabel(" ")            // ラベル名（デフォルトは，addKnobメソッドの引数値） 
     .setPosition(100, 300)    // GUIの右上の位置
     .setValue(false)          // 初期値
     .setSize(175, 175) ;
    
  // 逆回転用のボタン
  cp5.addToggle("reverseRotation") // addToggleメソッド
     .setLabel(" ")            // ラベル名（デフォルトは，addKnobメソッドの引数値） 
     .setPosition(400, 300)    // GUIの右上の位置
     .setValue(false)          // 初期値
     .setSize(175, 175) ;
     
  cp5.addToggle("Rotation0") // addToggleメソッド
     .setLabel(" ")            // ラベル名（デフォルトは，addKnobメソッドの引数値） 
     .setPosition(750, 80)    // GUIの右上の位置
     .setSize(50, 50) ;
     
  cp5.addToggle("Rotation1") // addToggleメソッド
     .setLabel(" ")            // ラベル名（デフォルトは，addKnobメソッドの引数値） 
     .setPosition(750, 180)    // GUIの右上の位置
     .setSize(50, 50) ;
     
  cp5.addToggle("Rotation2") // addToggleメソッド
     .setLabel(" ")            // ラベル名（デフォルトは，addKnobメソッドの引数値） 
     .setPosition(750, 280)    // GUIの右上の位置
     .setSize(50, 50) ;
     
  cp5.addToggle("Rotation3") // addToggleメソッド
     .setLabel(" ")            // ラベル名（デフォルトは，addKnobメソッドの引数値） 
     .setPosition(750, 380)    // GUIの右上の位置
     .setSize(50, 50) ;
     
  cp5.addToggle("Rotation4") // addToggleメソッド
     .setLabel(" ")            // ラベル名（デフォルトは，addKnobメソッドの引数値） 
     .setPosition(750, 480)    // GUIの右上の位置
     .setSize(50, 50) ;
  
  // 以下テキスト表示

  textSize(45);
  
  fill( #2f4f4f );         // 図形の塗りつぶし
  noStroke();              // 枠線なし
  rect(100, 100, 100, 100); // x座標，y座標，幅，高さ 
  fill(255, 255, 255);  // 文字色指定（今回は白）
  
  
  
   X = 0;
  Spx = 0;
  Acx =  0.25;
}

String Text = "Start"; // Arduinoから送信された文字列を受け取る文字列

// 以下描画設定
void draw(){
  
  if (port.available() > 0) {
    Text = port.readStringUntil('\n'); // Arduinoから送信された文字列を受け取る文字列
    if (Text != null){
      fill( #2f4f4f );         // 図形の塗りつぶし
      noStroke();              // 枠線なし
      rect(70, 70, 1000, 120); // x座標，y座標，幅，高さ
      println(pos);
      fill(255, 255, 255);  // 文字色指定（今回は白）
      text("Rotational Frequency : "+Text,75, 115);
      text("Max Rotation : "+max,75, 200);
      text("", 815, 120);
      text("Forward", 110, 270);
      text("Reverse", 410, 270);
      text("half power", 815, 120);
      text("Maxmum power", 815, 220);
      text("Minimum power", 815, 320);
      text("Rotation 3/4", 815, 420);
      text("Max", 815, 520);
    }    
  
    for (int i = 0; i < numberArray.length; i++) {
      Acx = numberArray[i];
    }
    
    Spx = Spx + Acx;            
    
    if (Spx > Max) {
      Spx = Max; 
    }
  
    X = X + Spx;        
    
    }
    
    //val=1が順回転，2が逆回転，0が停止
    // 順回転
    if(forwardRotation){ // チェックボックスの判定
      fill(color(255));
      val = 1;
      port.write(val); // Arduinoに 1(val) を送信
    } else if(reverseRotation) {
      fill(color(255));
      val = 2;
      port.write(val); // Arduinoに 2(val) を送信
    } else if(Rotation0) { //half
      fill(color(255));
      if(Text!=null){
        if(float(Text) < max*0.86){
          port.write(1);
        }else if(max*0.86 < float(Text)){
          port.write(2);
        }else if(max*0.86 == float(Text)){
          port.write(0);
        }
      }
      //val = 3;
      //port.write(val); // Arduinoに 3(val) を送信
    } else if(Rotation1) { //maxmum power
      fill(color(255));
      if(Text!=null){
        if(float(Text) < max){
          port.write(1);
        }else if(max < float(Text)){
          port.write(2);
        }else if(max == float(Text)){
          port.write(0);
        }
      }
    } else if(Rotation2) { //minimum power
      fill(color(255));
      if(Text!=null){
        if(float(Text) < 0){
          port.write(1);
        }else if(0 < float(Text)){
          port.write(2);
        }else if(0 == float(Text)){
          port.write(0);
        }
      }
      //val = 5;
      //port.write(val); // Arduinoに 5(val) を送信
    } else if(Rotation3) {
      fill(color(255));
      val = 6;
      port.write(val); // Arduinoに 6(val) を送信
    } else if(Rotation4) { //Maxボタン
      fill(color(255));
      if(Text!=null){
        max = float(Text); //最大回転数を記録
      }
      
      val = 7;
      port.write(val); // Arduinoに 6(val) を送信
      
    } else {
      noFill();
      val = 0;
      port.write(val); // Arduinoに 0(val) を送信
    }
  }
