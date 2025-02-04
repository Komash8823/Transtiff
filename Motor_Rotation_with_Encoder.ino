#define PIN_Encoder1  2 // エンコーダ用ピン
#define PIN_Encoder2  3 // エンコーダ用ピン
#define PIN_Motor1    7 // モータ用ピン
#define PIN_Motor2    8 // モータ用ピン
#define PIN_VREF      9 // PWM

//モータ用変数
unsigned long time_data = 0; // 時間計測用の変数
int val = 0; // Processingから受け取ったデータ格納用変数
int flag = 0;

//エンコーダ用変数
const int8_t ENCODER_TABLE[] = {0,-1,1,0,1,0,0,-1,-1,0,0,1,0,1,-1,0}; // "int8_t"は8ビットの符号付き整数型
volatile bool StatePin1 = 1;
volatile bool StatePin2 = 1;
volatile uint8_t State = 0; // "uint8_t"は8ビットの符号なし整数型
volatile long Count = 0;
volatile long baseCount = 0;

unsigned long start_time = 0, current_time = 0;

void setup(){
  Serial.begin(9600); //9600bpsでシリアルポートを開く
  //ピンのセットアップ
  pinMode(PIN_Motor1,OUTPUT); 
  pinMode(PIN_Motor2,OUTPUT);
  digitalWrite(PIN_Motor1,LOW);
  digitalWrite(PIN_Motor2,LOW);
  pinMode(PIN_Encoder1, INPUT_PULLUP);
  pinMode(PIN_Encoder2, INPUT_PULLUP);
  attachInterrupt(0, ChangePinAB, CHANGE);
  attachInterrupt(1, ChangePinAB, CHANGE);

  start_time = millis();
}

void loop(){
    /* 時間の計測・モニタへの表示
    time_data = millis();
    Serial.println(time_data / 1000.0);    
    */

    current_time = millis();

    if (Serial.available() > 0 && flag == 0) {   // シリアルポートからデータを受け取ったら
      val = Serial.read();
    }

    if (current_time - start_time > 100) {
      Serial.println(Count); // エンコーダで読み取った回転数をシリアルモニタへ出力
      start_time = millis();
    }
    
    /* モータの動作表-----------------
     * IN1      IN2     動作
     * LOW      LOW     ストップ
     * HIGH     LOW     回転
     * LOW      HIGH    逆回転
     * HIGH     HIGH    ブレーキ
    -------------------------------- */

    if (val == 0 && flag == 0) {
      digitalWrite(PIN_Motor1,LOW);
      digitalWrite(PIN_Motor2,LOW);
    }
    else if (val == 1 && flag == 0) { //forward
      digitalWrite(PIN_Motor1,HIGH);
      digitalWrite(PIN_Motor2,LOW);
    }
    else if (val == 2 && flag == 0) { //reverse
      digitalWrite(PIN_Motor1,LOW);
      digitalWrite(PIN_Motor2,HIGH);
    }
    else if (val == 3 && flag == 0) { //0/4
      if(abs(Count) > 1000){
        digitalWrite(PIN_Motor1,HIGH);
        digitalWrite(PIN_Motor2,HIGH);
      }else if(Count < 1000){ //順回転
        digitalWrite(PIN_Motor1,HIGH);
        digitalWrite(PIN_Motor2,LOW);
      }else{  //逆回転
        digitalWrite(PIN_Motor1,LOW);
        digitalWrite(PIN_Motor2,HIGH);
      }
      //baseCount = Count;
      //flag = 1;
    }

    if (abs(baseCount - Count) > 110 && flag == 1) {
      digitalWrite(PIN_Motor1,HIGH);
      digitalWrite(PIN_Motor2,HIGH);
      flag = 0;
    }
    
    /*
    // モーターの回転速度を中間にする
    analogWrite(PIN_VREF,127); 
 
    // 回転
    digitalWrite(PIN_Motor1,HIGH);
    digitalWrite(PIN_Motor2,LOW);
    delay(2000);
 
    // ブレーキ
    digitalWrite(PIN_Motor1,HIGH);
    digitalWrite(PIN_Motor2,HIGH);
    
    // 逆回転
    digitalWrite(PIN_Motor1,LOW);
    digitalWrite(PIN_Motor2,HIGH);    
    delay(2000);
 
    // ブレーキ
    digitalWrite(PIN_Motor1,HIGH);
    digitalWrite(PIN_Motor2,HIGH);
    delay(2000);
    
    // モーターの回転速度を最大にする
    analogWrite(PIN_VREF,255); 
    
    // 逆回転　
    digitalWrite(PIN_Motor1,LOW);
    digitalWrite(PIN_Motor2,HIGH);    
    delay(1000);
                
    // ストップ
    digitalWrite(PIN_Motor1,LOW);
    digitalWrite(PIN_Motor2,LOW);
    delay(2000);
    */
}

//エンコーダの記録用関数
void ChangePinAB(){
  StatePin1 = PIND & 0b00000100;
  StatePin2 = PIND & 0b00001000;
  State = (State<<1) + StatePin1;
  State = (State<<1) + StatePin2;
  State = State & 0b00001111;
  Count += ENCODER_TABLE[State];
}
