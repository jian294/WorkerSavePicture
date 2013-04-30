package
{
	import com.adobe.images.JPEGEncoder;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.system.MessageChannel;
	import flash.system.Worker;
	import flash.system.WorkerDomain;
	import flash.system.WorkerState;
	import flash.text.TextField;
	import flash.utils.ByteArray;
	import flash.utils.getTimer;
	
	public class WorkerSavePicture extends Sprite
	{
		[Embed(source="tmp.jpg")]    
		private var image:Class;   
		
		private var m_bitmapData: BitmapData;
		
		private var jpgEncoder: JPEGEncoder;
		
		private var imageBytes: ByteArray;
		
		private var worker: Worker;
		
		private var mainToWorker:MessageChannel;
		private var workerToMain:MessageChannel;
		
		private var m_tf: TextField;
		
		public function WorkerSavePicture()
		{
			if ( stage )
				init();
			else
				addEventListener( Event.ADDED_TO_STAGE, init );
		}
		
		private function init(e:Event = null): void
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
			
			/** 
			 * Start Main thread
			 **/
			if(Worker.current.isPrimordial)
			{
				m_bitmapData = (new image() as Bitmap).bitmapData;
				addChild(new RandomBalls());
				addChild(new Stats());
				
				m_tf = new TextField();
				addChild(m_tf);
				m_tf.x = 200;
				m_tf.width = 200;
				m_tf.backgroundColor = 0x00FFFFFF;
				m_tf.background = true;
				m_tf.text = "这是用了worker的\n点击舞台开始压缩图片";
				
				
				stage.addEventListener(MouseEvent.CLICK, _onClick);
				
				//Create worker from our own loaderInfo.bytes
				worker = WorkerDomain.current.createWorker(this.loaderInfo.bytes);
				
				//Create messaging channels for 2-way messaging
				mainToWorker = Worker.current.createMessageChannel(worker);
				workerToMain = worker.createMessageChannel(Worker.current);
				
				//Inject messaging channels as a shared property
				worker.setSharedProperty("mainToWorker", mainToWorker);
				worker.setSharedProperty("workerToMain", workerToMain);
				
				//Listen to the response from our worker
				workerToMain.addEventListener(Event.CHANNEL_MESSAGE, onWorkerToMain);
				
				//转换位图数据并存储到共享的byteArray对象里，与worker线程共享。
				imageBytes = new ByteArray();
				imageBytes.shareable = true;
				m_bitmapData.copyPixelsToByteArray(m_bitmapData.rect, imageBytes);
//				worker.setSharedProperty("imageBytes", imageBytes);
				
//				worker.setSharedProperty("imageWidth", m_bitmapData.width);
//				worker.setSharedProperty("imageHeight", m_bitmapData.height);
				
				//Start worker (re-run document class)
				worker.addEventListener ( Event.WORKER_STATE, workerStatusHandler ) ;
				worker.start();
			}
			else
			{
				mainToWorker = Worker.current.getSharedProperty("mainToWorker");
				workerToMain = Worker.current.getSharedProperty("workerToMain");
				
				//从共享属性缓存池里获取位图数据。
//				imageBytes = worker.getSharedProperty("imageBytes");
//				var w:int = worker.getSharedProperty("imageWidth");
//				var h:int = worker.getSharedProperty("imageHeight");
				
//				imageBytes.position = 0;
//				m_bitmapData = new BitmapData(w, h, false, 0x0);
//				m_bitmapData.setPixels(m_bitmapData.rect, imageBytes);
				
				mainToWorker.addEventListener(Event.CHANNEL_MESSAGE, onMainToWorker);
			}
		}
		
		
		private function _onClick(e: MouseEvent): void
		{
			mainToWorker.send(imageBytes);
			mainToWorker.send(m_bitmapData.width);
			mainToWorker.send(m_bitmapData.height);
			m_tf.appendText("\n开始压缩");
		}
		
		protected function onMainToWorker(event:Event):void 
		{
			var msg:* = mainToWorker.receive();
			
			if(msg is ByteArray)
			{
				imageBytes = msg;
				var w:int = mainToWorker.receive();
				var h:int = mainToWorker.receive();
				
				imageBytes.position = 0;
				m_bitmapData = new BitmapData(w, h, false, 0x0);
				m_bitmapData.setPixels(m_bitmapData.rect, imageBytes);
				
				if(jpgEncoder == null)
				{
					jpgEncoder = new JPEGEncoder();
				}
				jpgEncoder.encode(m_bitmapData);
				workerToMain.send("done");
			}
		}
		
		protected function onWorkerToMain(event:Event):void 
		{
			var msg: * = workerToMain.receive();
			trace("[Worker] " + msg);
			if(msg == "done")
			{
				m_tf.appendText("\n压缩完毕");
			}
		}
		
		private function workerStatusHandler ( evt:Event ) :void {
			var sState:String = ( evt.currentTarget as Worker ) .state;
			trace ( this, "workerStatusHandler:", sState, getTimer() ) ;
			/// 当副线程开始运行
			switch ( sState ) {
				case WorkerState.RUNNING:
					
					break;
			}
		}
	}
}