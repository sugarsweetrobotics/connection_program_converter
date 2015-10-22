import 'dart:core';

import 'package:connection_model/connection.dart';

import 'package:program_model/application.dart' as application;
import 'lib/converter.dart';


void main() {

  var app = new Application();

  var s0 = new Statement();
  var addBox = new Add(s0);
  var literal4 = new IntegerLiteral(s0, 4);
  var literal3 = new IntegerLiteral(s0, 3);
  var setvariableA = new SetVariable(s0, 'a');
  //var printBox = new Print(s0);
  addBox.in0.connect(literal4.out);
  //addBox.inport("in0").connect(literal4.outport("out"));  // Both by name and attribute, you can contact to ports.
  addBox.in1.connect(literal3.out);
  setvariableA.in0.connect(addBox.out);
  app.startState.next.connect(s0.previous);


  var s1 = new Statement();
  var ifbox = new If(s1);
  var getvariableA = new GetVariable(s1, 'a');
  var equalsBox = new Equals(s1);
  var literal7 = new IntegerLiteral(s1, 7);

  var s1_0 = new Statement(owner : s1);
  var stringA = new StringLiteral(s1_0, 'Hello');
  var printBoxA = new Print(s1_0);
  stringA.out.connect(printBoxA.in0);

  var s1_1 = new Statement(owner : s1);
  var stringB = new StringLiteral(s1_1, 'Good Bye');
  var printBoxB = new Print(s1_1);
  stringB.out.connect(printBoxB.in0);

  equalsBox.in0.connect(getvariableA.out);
  equalsBox.in1.connect(literal7.out);
  equalsBox.condition.connect(ifbox.condition);
  ifbox.yes.connect(s1_0.previous);
  ifbox.no.connect(s1_1.previous);

  s0.next.connect(s1.previous);


  var s2 = new Statement();
  var whilebox = new While(s2);
  var alwaysTrueBox = new TrueCondition(s2);

  var s2_0 = new Statement(owner : s2);
  var stringC = new StringLiteral(s2_0, 'This is Loop');
  var printBoxC = new Print(s2_0);
  stringC.out.connect(printBoxC.in0);

  whilebox.condition.connect(alwaysTrueBox.condition);
  whilebox.loop.connect(s2_0.previous);

  s1.next.connect(s2.previous);

  //print (app);

  Converter converter = new Converter();

  application.Application a = converter.convert(app);

  print (a.toPython(0));
}