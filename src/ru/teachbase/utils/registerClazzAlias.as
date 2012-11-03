package ru.teachbase.utils
{
	import flash.net.registerClassAlias;
	import flash.utils.getQualifiedClassName;
	
	/**
	 * @author Teachbase (created: May 4, 2012)
	 */
	public function registerClazzAlias(serializeOut:Class, serializeIn:Class = null):void
	{
		flash.net.registerClassAlias(getQualifiedClassName(serializeOut), serializeIn || serializeOut);
		flash.net.registerClassAlias(getQualifiedClassName(serializeOut).replace('::', '.'), serializeIn || serializeOut);
	}
}