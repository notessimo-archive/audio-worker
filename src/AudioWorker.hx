import haxe.ds.Option;
import haxe.io.Float32Array;

import net.rezmason.utils.workers.BasicBoss;
import net.rezmason.utils.workers.QuickBoss;

using OptionTools;

typedef AudioBoss<T> = QuickBoss<AudioWorkerParams<T>, Float32Array>;

@:generic
class AudioWorker<T> {

    var _buffers : Array<Float32Array> = [];
    var _golem : Core<AudioWorkerParams<T>, Float32Array>;

    var _boss : Option<AudioBoss<T>> = None;

    var _bufferSamples : Int;
    var _sampleRate : Float;
    var _nBuffer : Int;

    var _position : Int;

    var _requestBuffer : Option<Int->T> = None;

    /**
     *  Create a new AudioWorker
     *  
     *  @param golem - usage: Golem.rise('../hxml/Worker.hxml')
     *  @param nBuffer - Number of buffers to keep in memory
     *  @param sampleRate - Sample rate
     */
    public static function create<T>( golem, bufferSamples : Int = 8192, sampleRate : Float = 44100.0, ?nBuffer : Int = 2 ) {
        var worker = new AudioWorker<T>(golem, bufferSamples, sampleRate, nBuffer);
        return worker;
    }

    public function new( golem, bufferSamples : Int, sampleRate : Float, nBuffer : Int ) {
        if (golem == null) throw('You need to rise a golem');

        _golem = golem;
        
        _bufferSamples = bufferSamples;
        _sampleRate = sampleRate;
        _nBuffer= nBuffer;

        _position = 0;
    }

    public function requestBufferUsing( requestBuffer : Int->T ) {
        _requestBuffer = Some(requestBuffer);

        return this;
    }

    public function stop() {
        switch( _boss ) {
            case Some(boss) : boss.die();
            case None : 
        }

        _boss = None;

        return this;
    }

    public function start() : AudioWorker<T> {
        stop();

        var boss = new AudioBoss(_golem, (buffer) -> {
            _buffers.push(buffer);
            checkMissingBuffers();
        }, (error) -> start());

        _boss = Some(boss);

        boss.start();

        checkMissingBuffers();
        
        return this;
    }

    public function generator( out : Float32Array, sampleRate : Float ) {
        var buffer = _buffers.pop().option();
        switch( buffer ) {
            case Some(buffer) : for( i in 0...out.length ) out.set(i, buffer.get(i));
            case None : for( i in 0...out.length ) out.set(i, 0.0);
        }

        checkMissingBuffers();
    }

    function checkMissingBuffers() {
        if( _buffers.length < _nBuffer ) {
            switch( _requestBuffer ) {
                case Some(requestBuffer) : send(requestBuffer(_position));
                case None : send();
            }

            _position += _bufferSamples;
        }
    }

    function send( ?data : T = null ) {
        switch( _boss ) {
            case Some(boss) : boss.send({ samples: _bufferSamples, sampleRate: _sampleRate, data : data});
            case None : 
        }
    }
}