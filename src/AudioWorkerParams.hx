import haxe.io.Bytes;

typedef AudioWorkerParams = {
    var samples : Int;
    var sampleRate : Float;
    @:optional var data : Bytes;
}