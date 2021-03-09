//
//  ContentView.swift
//  hw-guessing
//
//  Created by falcon on 2021/3/5.
//

import SwiftUI
import AVFoundation

struct question {
  var question: String
  var answer: String
  
  init(q: String, a: String) {
    self.question = q
    self.answer = a
  }
}

var quesions = Array<question>()
var utter: AVSpeechUtterance = AVSpeechUtterance()
var synth: AVSpeechSynthesizer = AVSpeechSynthesizer()

struct ContentView: View {

  @State var q: question
  @State var qShow: String
  @State var showingAnswer: Bool = false
  @State var getHelp: Bool = true
  @State var progress: Int = 0
  @State var hasSeenAnswer: Bool = true
  @State var autoSpeech: Bool = false
  
  let numberOfQuestions = 10

  var body: some View {
    VStack{
      Text("廢到爆猜謎")
        .font(.system(size: 32))
        .padding(.bottom, 10).padding(.top, 0)

      if(progress < numberOfQuestions + 1){
        HStack{
          Button(action: _getQuestion){
            Image(systemName: "arrow.forward")
              .font(.system(size: 30))
              .foregroundColor(buttonColor(logicWhenEnabled: hasSeenAnswer))
          }.padding(.leading, 20).padding(.trailing, 20)
            .disabled(!hasSeenAnswer)
          
          Button(action: toggleQuestion){
            Image(systemName: "key")
              .font(.system(size: 30))
              .foregroundColor(.green)
          }.padding(.leading, 20).padding(.trailing, 20)
          
          Button(action: { self.getHelp = !self.getHelp }){
            Image(systemName: "questionmark.circle")
              .font(.system(size: 30))
              .foregroundColor(.green)
          }.padding(.leading, 20).padding(.trailing, 20)

          Button(action: toggleSpeech){
            Image(systemName: (autoSpeech) ? "speaker.wave.2" : "speaker.slash")
              .font(.system(size: 30))
              .foregroundColor(.green)
          }.padding(.leading, 20).padding(.trailing, 20)
        }
        Text("\(progress)/10")
          .padding(.bottom, 150).padding(.top, 20)
        
        HStack{
          if(self.getHelp){
            VStack{
              Text("按下 \(Image(systemName: "arrow.forward")) 去下一題")
              Text("按下 \(Image(systemName: "key")) 取得答案")
              Text("按下 \(Image(systemName: "questionmark.circle")) 查看這則訊息")
              Text("按下 \(Image(systemName: "speaker.wave.2")) 讓 iPhone 幫你念題目或答案")
            }
          }
          else{
            VStack{
              if(showingAnswer){
                Text("\(Image(systemName: "text.bubble"))答：")
                  .font(.system(size: 22))
              }
              else{
                Text("\(Image(systemName: "person.fill.questionmark"))問：")
                  .font(.system(size: 22))
              }
              Text(qShow)
                .font(.system(size: 22))
            }
          }
        }
        .padding(.bottom, 120).padding(.leading, 15).padding(.trailing, 15)
      }
      else{
        VStack{
          Text("遊戲結束！按下\(Image(systemName: "arrow.uturn.left.circle"))重新開始！")
          Button(action: reset){
            Image(systemName: "arrow.uturn.left.circle")
              .font(.system(size: 60)).foregroundColor(.green).padding(40)
          }
        }
      }
    }
    .onAppear {
      quesions = generateQuestions()
    }
  }

  func _getQuestion() {
    self.q = getQuestion(q: quesions)
    self.qShow = self.q.question
    self.showingAnswer = false
    self.getHelp = false
    self.progress += 1
    self.hasSeenAnswer = false
    if(self.autoSpeech) { speak() }
  }
  
  func reset() {
    self.showingAnswer = false
    self.getHelp = false
    self.progress = 1
    self.hasSeenAnswer = true
    speak()
  }
  
  func buttonColor(logicWhenEnabled: Bool) -> Color{
    return logicWhenEnabled ? .green : .gray
  }

  func toggleQuestion() {
    if(self.qShow == self.q.question) {
      self.qShow = self.q.answer
      self.showingAnswer = true
      self.hasSeenAnswer = true
      if(self.autoSpeech) { speak() }
    }
    else {
      self.qShow = self.q.question
      self.showingAnswer = false
    }
  }
  
  func toggleSpeech() {
    if(synth.isSpeaking) { synth.stopSpeaking(at: .immediate) }
    var message = ""
    if(self.autoSpeech){ message = "好吧，我安靜" }
    else{ message = "安安你好，我現在會幫你念題目呦" }
    utter = AVSpeechUtterance(string: message)
    utter.voice = AVSpeechSynthesisVoice(language: "zh-TW")
    synth = AVSpeechSynthesizer()
    synth.speak(utter)
    self.autoSpeech = !self.autoSpeech
  }
  
  func speak() {
    if(synth.isSpeaking) { synth.stopSpeaking(at: .immediate) }
    var speech = ""
    if(progress == numberOfQuestions + 1){
      speech = "好了，十題結束，要繼續的話就按下面那個按鈕。"
    }
    else if(self.qShow == self.q.question) {
      speech = "問題，\(qShow)"
    }
    else {
      let rnd = Int.random(in: 0...10)
      speech = "答案是，\(qShow)"
      if(rnd == 3){ speech += "，哈哈" }
      else if(rnd == 6){ speech += "，我知道，爛死了，ㄏㄏ" }
    }
    utter = AVSpeechUtterance(string: speech)
    utter.voice = AVSpeechSynthesisVoice(language: "zh-TW")
    synth = AVSpeechSynthesizer()
    synth.speak(utter)
  }
}

func readLocalJson() -> Array<Dictionary<String, String>>{
  print(readLocalJson)
  let path = Bundle.main.path(forResource: "questions", ofType: "json")
  do{
    let data = try Data(contentsOf: URL(fileURLWithPath: path!), options: .mappedIfSafe)
    let jsonR = try JSONSerialization.jsonObject(with: data, options: .mutableLeaves)
    let parsed = jsonR as? Array<Dictionary<String, String>> ?? []
    return parsed
  }catch{
    return []
  }
}

func generateQuestions() -> Array<question> {
  let rq = readLocalJson();
  var qs = Array<question>()
  for q in rq{
    qs.append(question(q: q["question"] ?? "這題壞了", a: q["answer"] ?? "壞了還有答案啊？"))
  }
  return qs
}

func getQuestion(q: Array<question>) -> question {
  let index = Int.random(in: 0...(q.count - 1))
  let rq = q[index]
  return rq
}
