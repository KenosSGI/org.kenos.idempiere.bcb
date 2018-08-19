package org.kenos.idempiere.bcb.process;

import org.adempiere.base.IProcessFactory;
import org.compiere.process.ProcessCall;

/**
 * 		Process Factory
 * 
 * 	@author Ricardo Santana (Kenos, www.kenos.com.br)
 *	@version $Id: ProcessFactory.java, v1.0 2018/08/18 5:06:32 PM, ralexsander Exp $
 */
public class ProcessFactory implements IProcessFactory
{
	@Override
	public ProcessCall newProcessInstance (String className)
	{
		if (GetConversion.class.getName().equals (className) || GetConversion.LEGACY_CLASSNAME.equals (className))
			return new GetConversion ();
		return null;
	}	//	newProcessInstance
}	//	ProcessFactory
