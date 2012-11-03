package ru.teachbase.utils
{
	import flash.display.Stage;
	import flash.events.MouseEvent;
	import flash.events.StatusEvent;
	import flash.media.Camera;
	import flash.media.Microphone;
	import flash.media.Video;
	import flash.media.scanHardware;
	import flash.net.NetConnection;
	import flash.net.NetStream;
	import flash.security.CertificateStatus;
	import flash.system.Security;
	import flash.system.SecurityPanel;
	import flash.system.System;
	import flash.utils.setTimeout;
	
	import mx.rpc.Responder;
	
	import ru.teachbase.utils.Logger;
	
	/**
	 * 
	 * @param mic/cam  indexes in <code>names</code> array in <code>Camera</code> or <code>Microphone</code> classes. <br/>
	 * 	<b>- values</b>: <br/>
	 * -2 = do not try get access;
	 * <br/>
	 * -1 = request access to <b>default</b> media-device;
	 * <br/>
	 * 0+ = request access to media-device by zero-based index position within the Camera.names (or Microphone.names) array.
	 * 
	 * @param responder responder that holds <code>result()</code> and <code>fault()</code>. <br/>
	 * If user allowed media access then <code>result()</code> is called; otherwise <code>fault()</code>
	 * 
	 * @param stage main stage object (we need it to detect when player closes secutiry dialog)
	 *  
	 * @author Teachbase (created: Jun 19 - Oct 29, 2012)
	 */	
	public function requestUserMediaAccess(mic:int = -2, cam:int = -2, responder:Responder = null, stage:Stage = null):void
	{
		flash.media.scanHardware();
		
		const needMic:Boolean = mic >= -1;
		const needCam:Boolean = cam >= -1;
		
		var status:Boolean = false;
		
		const connection:NetConnection = new NetConnection();
			  connection.connect(null);
			  
		const stream:NetStream = new NetStream(connection);
		var target:*;
		var video:Video;
		// try use camera:
		if(needCam && Camera.isSupported)
		{
			const camera:Camera = cam === -1 ? Camera.getCamera() : Camera.getCamera(cam.toString());
			if(camera.muted)
			{
				camera.addEventListener(StatusEvent.STATUS, camStatusHanler);
				target = camera;
				video = new Video();
				video.attachCamera(camera);
				stream.attachCamera(camera);
				stream.publish('devnull');
			}
			else{
				responder && responder.result is Function && responder.result(true);
				return;
			}
		}
		else
		if(needMic && Microphone.isSupported)
		{
			const microphone:Microphone = Microphone.getMicrophone(mic);
			if(microphone.muted)
			{
				microphone.addEventListener(StatusEvent.STATUS, camStatusHanler);
				target = microphone;
				stream.attachAudio(microphone);
				stream.publish('devnull');
			}
			else{
				responder && responder.result is Function && responder.result(true);
				return;
			}
		}
		
		if(Camera.isSupported || Microphone.isSupported)
		{
			showSecurityPanel();
		}
		else
			responder && responder.fault is Function && responder.fault('not supported');
		
		
		stage && setTimeout(stage.addEventListener,500,MouseEvent.MOUSE_MOVE, panelClosedHandler);
		
		function panelClosedHandler(e:MouseEvent):void{
			
			if (e.stageX >= 0 && e.stageX < stage.stageWidth && e.stageY >= 0 && e.stageY < stage.stageHeight){
				
				target && target.removeEventListener(StatusEvent.STATUS, camStatusHanler);
				stage.removeEventListener(MouseEvent.MOUSE_MOVE,panelClosedHandler);
				if(stream){
					stream.attachAudio(null);
					stream.attachCamera(null);
					stream.dispose();
				}
				if(video){
					video.attachCamera(null);
					video.clear();
				}
				video = null;
				target = null;
				if(status){
					Logger.log('success','media_access');
					responder && responder.result is Function && responder.result(true);
				}else{
					Logger.log('fail','media_access');
					responder && responder.fault is Function && responder.fault('access denied');
				}
			}
			
		}
		
		
		function camStatusHanler(e:StatusEvent):void
		{
			Logger.log(e.code,'media_access');
			if(e.code === "Camera.Unmuted")
				status = true;
			else
				status = false;
		}
	}
}


import flash.display.Stage;
import flash.events.Event;
import flash.system.Security;
import flash.system.SecurityPanel;

internal function showSecurityPanel():void
{
	Security.showSettings(SecurityPanel.PRIVACY);
}

