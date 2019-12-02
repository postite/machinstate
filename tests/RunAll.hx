import machine.FSM;

import utest.Assert;

class RunAll{

   public static function main(){

      utest.UTest.run([
        // new TestBase(),
         new TestOtherConds()
         ]);
   }

}
@:access(machine.FSM)
class TestBase extends utest.Test{
   var fsm:machine.FSM;
   function setup(){
      fsm= new FSM();
      fsm.add(MockStateA,[
         {cond:Sbool(false),state:MockStateB},
         {cond:Sbool(true),state:MockStateC}
         ]);
      fsm.add(MockStateC,[
         {cond:Sbool(false),state:MockStateA},
         {cond:Sbool(true),state:MockStateB}
         ]);
      fsm.add(MockStateB,[
         {cond:Sbool(true),state:MockStateA},
         {cond:Sbool(false),state:MockStateC}
         ]);
   }

   function testtest(){
      Assert.isTrue(1==1);
   }

   function testnext(){     
      fsm.next();
      Assert.notNull(fsm.currentStateId);
   }

   function testAnswer(){
      fsm.next();
      Assert.equals(fsm.currentStateId,fsm.curList.last());
   }

   function teardown(){
      fsm=null;
   }

}

@:access(machine.FSM)
class TestOtherConds extends utest.Test{
   var fsm:machine.FSM;
   function setup(){
         fsm= new FSM();
         fsm.add(MockStateD,[
         {cond:Sbool(false),state:MockStateB},
         {cond:Val(10),state:MockStateA}
         ]);
   }

   function testValue(){
      fsm.next();
      Assert.equals(10,fsm.payload);
   }

}

class MockStateA extends machine.FSM.StateBase{

   function new(id,fsm){
      super(id,fsm);

   }

   override function resolve():StateCond{
      fsm.answer(id,Sbool(true));
      return Sbool(true);
   }

}

class MockStateB extends machine.FSM.StateBase{
   override function resolve():StateCond{
      fsm.answer(id,Sbool(true));
      return Sbool(true);
   }
}
class MockStateC extends machine.FSM.StateBase{
   override function resolve():StateCond{
      fsm.answer(id,Sbool(true));
      return Sbool(true);
   }
}

class MockStateD extends machine.FSM.StateBase{
   override function resolve():StateCond{
      fsm.answer(id, Val(2) );
      return null;
   }
}