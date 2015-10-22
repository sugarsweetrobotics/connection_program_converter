library converter.converter;

import 'dart:core';
import 'package:connection_model/connection.dart' as cm;
import 'package:program_model/application.dart' as pm;

class InvalidModelException implements Exception {

  const InvalidModelException();
}

class Converter {

  Converter() {}

  pm.Application convert(cm.Application src) {
    pm.Application app = new pm.Application();

    src.iterStatement((cm.Statement s) {
      app.statements.add(parseStatement(s));
    });
    return app;
  }

  pm.Statement parseStatement(cm.Statement cs) {
    var list = [];
    for(cm.Box box in cs.boxes) {
      if (box is cm.SetVariable) {
        // If setVariable statement is included, it is value of statement.
        return new pm.Statement(parseSetValue(box));
      } else if (box is cm.If) {
        return new pm.Statement(parseIf(box));
      } else if (box is cm.While) {
        return new pm.Statement(parseWhile(box));
      } else if (box is cm.Print) {
        return new pm.Statement(parsePrint(box));
      }
    }
    return null;
  }



  cm.Box childBox(cm.Port port) {
    return port.connections[0].ports[0] == port ? port.connections[0].ports[1].owner : port.connections[0].ports[0].owner;
  }

  cm.Statement childStatement(cm.Port port) {
    return port.connections[0].ports[0] == port ? port.connections[0].ports[1].owner : port.connections[0].ports[0].owner;
  }

  pm.Block parseBlock(cm.Box box) {
    if (box is cm.Statement) {
      return paraseStatement(box);
    } else if (box is cm.Add) {
      return parseAdd(box);
    } else if (box is cm.Subtract) {
      return parseSubtract(box);
    } else if (box is cm.IntegerLiteral) {
      return parseInteger(box);
    } else if (box is cm.GetVariable) {
      return parseGetValue(box);
    } else if (box is cm.Print) {
      return parsePrint(box);
    } else if (box is cm.StringLiteral) {
      return parseString(box);
    } else if (box is cm.If) {
      return parseIf(box);
    }
  }

  pm.If parseIf(cm.If ifbox) {
    var yeslist = new pm.StatementList([]);
    var nolist = new pm.StatementList([]);
    pm.Condition block = parseCondition(childBox(ifbox.condition));
    cm.Application.mapStatement(childStatement(ifbox.yes), (cm.Statement s) {
      print (s);
      yeslist.add(parseStatement(s));
    });
    cm.Application.mapStatement(childStatement(ifbox.no), (cm.Statement s) {
      nolist.add(parseStatement(s));
    });

    return new pm.If(block, yeslist, no : nolist );
  }

  pm.While parseWhile(cm.While whilebox) {
    var list = new pm.StatementList([]);
    pm.Condition block = parseCondition(childBox(whilebox.condition));
    cm.Application.mapStatement(childStatement(whilebox.loop), (cm.Statement s) {
      list.add(parseStatement(s));
    });

    return new pm.While(block, list);
  }

  pm.Equals parseEquals(cm.Equals eq) {
    return new pm.Equals(
        parseBlock(childBox(eq.in0)),
        parseBlock(childBox(eq.in1)));
  }

  pm.TrueLiteral parseTrue(cm.TrueCondition tr) {
    return new pm.TrueLiteral();
  }

  pm.Condition parseCondition(cm.Box box) {
    if (box is cm.Equals) {
      return parseEquals(box);
    } else if (box is cm.TrueCondition) {
      return parseTrue(box);
    }
  }

  pm.Integer parseInteger(cm.IntegerLiteral box) {
    return new pm.Integer(box.value);
  }

  pm.Add parseAdd(cm.Add add) {
    return new pm.Add(
        parseBlock(childBox(add.in0)),
        parseBlock(childBox(add.in1)));
  }

  pm.Subtract parseSubtract(cm.Subtract sub) {
    return new pm.Subtract(
        parseBlock(childBox(sub.in0)),
        parseBlock(childBox(sub.in1)));
  }

  pm.SetValue parseSetValue(cm.SetVariable box) {
    var v = new pm.Variable(box.name);
    if (box.in0.connections.length == 0) {
      throw InvalidModelException();
    }
    pm.Block block = parseBlock(childBox(box.in0));
    return new pm.SetValue(v, block);
  }

  pm.Variable parseGetValue(cm.GetVariable box) {
    return new pm.Variable(box.name);
  }

  pm.StringLiteral parseString(cm.StringLiteral box) {
    return new pm.StringLiteral(box.value);
  }

  pm.Print parsePrint(cm.Print box) {
    return new pm.Print(parseBlock(childBox(box.in0)));
  }
}