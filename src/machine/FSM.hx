package machine;
using tink.CoreApi;
import haxe.ds.List;
import haxe.ds.Option;
using haxe.EnumTools.EnumValueTools;
using haxe.io.Path;
enum StateCond{
   Sbool(b:Bool);
   Val(n:Any);
   Named(n:String);
}

typedef Toz={
   ?id:String,
   state:StateBaseClass,
   cond:StateCond,
   
}
typedef StateBaseClass=Class<StateBase>;

class FSM{

  public var currentStateId:String;
  public var prevStateId:String;
  //active following
   public var following:Bool= false;

   public var currentStateName:String;
   var tozMap:Map<String,Array<Toz>>;
   var stateMap:Map<String,StateBase>;
   var curList:haxe.ds.List<String>;
   var iter:Iterator<String>;
   var payload:Any;

   public function new(){
      trace( "new");
      tozMap=[];
      stateMap=[];
      curList=new List();
   }

   public function add(s:StateBaseClass,toz:Array<Toz>,?name:String){

         //following beahaviour
         if(following)return addF(s,toz);

         if (name==null)
         name= Type.getClassName(s).split(".").pop();//get name;
        //var state=Type.createInstance(s,[id,this]);
        var state=createStateInstance(s,name);
        var id=state.id;
        stateMap.set(id,state);        
        tozMap.set(id,toz);
        curList.add(id);
        
        iter=curList.iterator(); 
   }

   function createStateInstance(s:StateBaseClass,?name:String):StateBase{
      var id=generateId();
       var state=Type.createInstance(s,[id,this,name]);
       return state;
   }

   public function answer(id,cond:StateCond){
      if (id==prevStateId)return; // evite les doublons
         //following beahaviour
         if(following)return answerF(id,cond);

      trace("answer " +id);
         switch(chooseToz(id,cond)){
            case Some(v):
                  trace("next is" + v);                  
                  next();
            case None: 
               trace( "nope");
         }

   }

   function generateId():String{
      var alf="abcedfefghigjijbytvghgdysdsdd";
      var _id= "";
      for ( a in 0 ... 5){
         var r=Std.random(alf.length);
            _id+=alf.substr(r,1);
      }
      return _id;
   }

   public function chooseToz(id,cond:StateCond):Option<StateBaseClass>{
   var toz=tozMap.get(id);

   var ret:Option<StateBaseClass>=None;
      for ( a in toz){ 
         trace( "yo");
         ret= switch(a.cond){
            case Sbool(b):
               trace(a.cond +"="+cond);
               if(Type.enumEq(a.cond,cond)){
                  payload=cond.getParameters()[0];
                return Some(a.state);
                  break;
               }
                None;
            case Val(v):

                  trace( "val"+a.cond +"="+cond);
                  trace(a.cond.getName());
                  trace(a.cond.getName() == cond.getName());
                  if(a.cond.getName()==cond.getName()){
                     payload=cond.getParameters()[0];
                     trace( "payloade="+payload);
                     return Some(a.state);
                   break;
                  }
               
               None;
               case Named(n):
                  trace(a.cond +"="+cond);
               if(Type.enumEq(a.cond,cond)){
                  payload=cond.getParameters()[0];
                return Some(a.state);
                  break;
               }
                None;
              

         }

      }
      
      return ret;
   }

   function getState(id:String):StateBase{
      return stateMap.get(id);
   }
   function getId(stateclass:StateBaseClass):Option<String>{
      var exists= (Lambda.find(stateMap, base->
        Std.is(base,stateclass)
      ));
      if (exists!=null)
         return Some(exists.id);
         return None;
   }

   function getClassbyState(state:StateBase):StateBaseClass{
      return Type.getClass(state);
   }

   function getStateByClass(stateclass:StateBaseClass):Option<StateBase>{
      return switch getId(stateclass){
         case Some(id):
            Some(getState(id));
         case None:
            None;
      }
   }

   public function answerF(id,cond:StateCond){
      
      trace("answerF " +id);
         switch(chooseToz(id,cond)){
            case Some(v):
                  trace("follow is" + v);
                  switch(getStateByClass(v)){
                     case Some(s):
                        follow(s);
                     case None:
                        var state= createStateInstance(v);
                        stateMap.set(state.id,state);
                        follow(state);
                  }
                  
            case None: 
               trace( "nope");
         }

   }

  

   public function addF(s:StateBaseClass,toz:Array<Toz>){
      var id=generateId();
      var state=Type.createInstance(s,[id,this]);
      stateMap.set(id,state);
      tozMap.set(id,toz);
      curList.add(id);
      iter=curList.iterator();
   }

   public function follow(s:StateBase){
      //memo
      if (currentStateId!=null)
      prevStateId=currentStateId;

      var curstate=s;
      currentStateId=s.id;
      currentStateName=s.name;
      
      if( payload!=null){
         curstate.set_Payload(payload);
      }
      curstate.enter(payload);
      #if tested
         trace( "tested");
         getState(currentStateId).resolve();
      #end

   }

   public function next(){
      trace( "next" +curList.length);
      if (iter.hasNext()){
         trace( "hasnext");
         currentStateId=iter.next();

         trace('currentStateId = $currentStateId');
         try{
         var curstate=getState(currentStateId);
         currentStateName=curstate.name;
         trace("currentStateName"+currentStateName);
         if( payload!=null){
         curstate.set_Payload(payload);
         }
         trace( "------------------payload="+payload);
         
         curstate.enter(payload);
         #if tested
         trace( "tested");
         getState(currentStateId).resolve();
         #end
         }catch(msg:Any){
            trace(msg);
         }
      }
    //  var curd= currentState.id;
   }

   public function back(){

   }

}


interface IState{

}


@:allow(FSM)
class StateBase implements IState{

   @:isVar public var id(get,null):String; /// done by FSM

   @:isVar public var name(default,null):String; //done by FSM

   function get_id():String 
      return return id;

   var fsm:FSM;
   var payload:Promise<Dynamic>;
   var pt=Promise.trigger();
   private function new(id:String,fsm:FSM,name:String){
      this.id=id;
      this.name=name;
      this.fsm=fsm;
      payload=pt.asPromise();

   }
   public function set_Payload(n){
      payload=pt.resolve(n);
   }
   public function enter(payload:Any){
     
   }
   public function resolve():StateCond{
      //fsm.answer(true);
     // throw 'override me';
     return null;
   }



}