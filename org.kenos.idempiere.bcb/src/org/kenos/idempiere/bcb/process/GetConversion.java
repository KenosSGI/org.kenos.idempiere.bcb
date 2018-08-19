package org.kenos.idempiere.bcb.process;

import java.io.FileNotFoundException;
import java.io.InputStream;
import java.math.BigDecimal;
import java.net.URL;
import java.sql.Timestamp;
import java.text.MessageFormat;
import java.util.Scanner;
import java.util.logging.Level;

import org.adempierelbr.util.TextUtil;
import org.compiere.model.MConversionRate;
import org.compiere.model.MCurrency;
import org.compiere.process.ProcessInfoParameter;
import org.compiere.process.SvrProcess;
import org.compiere.util.DB;
import org.compiere.util.Msg;
import org.compiere.util.TimeUtil;

/**
 * 		Captura os dados da cotação de moedas PTAX do BCB
 * 
 * 	@author Ricardo Santana (Kenos, www.kenos.com.br)
 *	@version $Id: GetConversion.java, v1.0 2018/08/19 6:17:27 PM, ralexsander Exp $
 */
public class GetConversion extends SvrProcess
{
	/**	Moeda							*/
	private int p_C_Currency_ID = -1;
	
	/** Moedas separadas por vírgula	*/
	private String p_ISO_Codes = null;
	
	/** Data da Cotação da Moeda		*/
	private Timestamp p_DateTrx;
	
	/** Legacy ClassName				*/
	public static final String LEGACY_CLASSNAME = "org.kenos.adempiere.bcb.GetConversion";

	/**
	 * 	Prepare
	 */
	@Override
	protected void prepare()
	{
		ProcessInfoParameter[] para = getParameter();
		for (int i = 0; i < para.length; i++)
		{
			String name = para[i].getParameterName();
			if (para[i].getParameter() == null)
				;

			else if (name.equals("C_Currency_ID"))
				p_C_Currency_ID = para[i].getParameterAsInt();

			else if (name.equals("ISO_Code"))
				p_ISO_Codes = (String) para[i].getParameter();
			
			else if (name.equals("DateTrx"))
				p_DateTrx = (Timestamp)para[i].getParameter();
			
			else
				log.log (Level.SEVERE, "prepare - Unknown Parameter: " + name);
		}
	}	//	prepare

	/**
	 * 	Do It
	 */
	@Override
	protected String doIt () throws Exception
	{
		InputStream in = null;
		Scanner csv = null;
		String currencies = null;
		
		//	Moeda passada por parâmetro
		if (p_C_Currency_ID > 0)
			currencies = new MCurrency (getCtx(), p_C_Currency_ID, get_TrxName()).getISO_Code();

		//	Pesquisar moedas padrão
		else if (p_ISO_Codes != null && p_ISO_Codes.length() > 0)
			currencies = p_ISO_Codes;
		
		//	Verifica se há alguma moeda para continuar
		if (currencies == null || currencies.length() < 1)
			return "@Error@ Sem moeda para pesquisar";
		
		//	Resultado
		String result = "@Success@";
		
		try 
		{
			String url = new MessageFormat ("https://www4.bcb.gov.br/Download/fechamento/{0}.csv")
					.format (new String[]{TextUtil.timeToString (p_DateTrx, "yyyyMMdd")});
			
			statusUpdate (Msg.getMsg(getCtx(), "Processing") + " ... Download");

			in = new URL (url).openStream ();
			csv = new Scanner (in);
			//
			while (csv.hasNextLine ())
			{
				//	Next line
				String line = csv.nextLine();
				
				//	Columns
				String[] cols = line.split (";");
				if (cols != null && cols.length == 8)
				{
					//	Currency
					String currency = cols[3];
					
					//	Check if this currency should be saved
					if (currencies.indexOf (currency) != -1)
					{
						statusUpdate (Msg.getMsg(getCtx(), "Processing") + " ... " + currency);

						try
						{
							//	O valor PTAX será válido somente a partir do dia seguinte
							Timestamp date = TimeUtil.addDays (TextUtil.stringToTime (cols[0], "dd/MM/yyyy"), 1);
							BigDecimal rate = new BigDecimal (cols[4].replace(".", "").replace(",", "."));
							
							//	Adiciona a conversão da moeda
							MConversionRate.setRate (currency, "BRL", date, rate);
							
							//	Ajusta a conversão para valer até 7 dias
							String sql = "UPDATE C_Conversion_Rate SET ValidTo=" + DB.TO_DATE (TimeUtil.addDays (date, 7)) 
											+ " WHERE C_Currency_ID=" + MCurrency.get (getCtx(), currency).getC_Currency_ID()
											+ " AND C_Currency_ID_To=" + MCurrency.get (getCtx(), "BRL").getC_Currency_ID()
											+ " AND ValidFrom=ValidTo"
											+ " AND ValidFrom=" + DB.TO_DATE (date)
											+ " AND AD_Client_ID=0 AND AD_Org_ID=0";
							DB.executeUpdate (sql, null);
							
							//	Adiciona informação no log
							addLog (cols[0] + " | " + currency + " = " + cols[4]);
						}
						finally {}
					}
				}
			}
		}
		catch (FileNotFoundException e)
		{
			result = "@Error@\nCotação não encontrada para o dia " + TextUtil.timeToString (p_DateTrx, "dd/MM/yyyy");
		}
		finally 
		{
			if (in != null)
				in.close();
			if (csv != null)
				csv.close();
		}
		return result;
	}	//	doIt
}	//	GetConversion
