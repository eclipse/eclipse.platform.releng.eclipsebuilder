/*******************************************************************************
 * Copyright (c) 2000, 2005 IBM Corporation and others.
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 * 
 * Contributors:
 *     IBM Corporation - initial API and implementation
 *******************************************************************************/
/**
 * This class finds the version of a plug-in, or fragment listed in a feature
 * and writes <element>=<element>_<version> for each in a properties file.
 * The file produced from this task can be loaded by an Ant script to find files in the
 * binary versions of plugins and fragments.
 */

import org.xml.sax.Attributes;
import org.xml.sax.helpers.DefaultHandler;

import javax.xml.parsers.ParserConfigurationException;
import javax.xml.parsers.SAXParser;
import javax.xml.parsers.SAXParserFactory;
import org.xml.sax.SAXException;
import java.io.*;
import java.util.Arrays;
import java.util.Hashtable;
import java.util.Enumeration;
import java.util.StringTokenizer;
import java.util.Vector;

public class TestVersionTracker{

	private String buildDirectory;
	private Hashtable elements;
	private SAXParser parser;
	//private Vector allElements;
	private Hashtable testElements;
	
	//the feature to from which to collect version information
	private String featurePath;
	
	//the path to the file in which to write the results
	private String outputFilePath;
	
	public static void main(String[] args) {
		String buildDirectory=(args[0].substring(0,args[0].length()-10))+"/../..";
		TestVersionTracker Tracker =
		new TestVersionTracker(buildDirectory);
		Tracker.parse(args[0],Tracker.new FeatureHandler());
		Tracker.writeProperties(args[1], true);
	}

	public TestVersionTracker(){}
	
	public TestVersionTracker(String install) {
		elements = new Hashtable();
		testElements=new Hashtable();
		
		SAXParserFactory saxParserFactory = SAXParserFactory.newInstance();
		try {
			parser = saxParserFactory.newSAXParser();
		} catch (ParserConfigurationException e) {
		  	e.printStackTrace();
		} catch (SAXException e) {
			e.printStackTrace();
		}
        
       	// directory containing the source for a given build
		buildDirectory = install;
	}

    public void parse(String xmlFile,DefaultHandler handler){
         try {
          parser.parse(xmlFile,handler);
        } catch (SAXException e) {
            System.err.println (e);
        } catch (IOException e) {
            System.err.println (e);    
        } 
    }

    private class FeatureHandler extends DefaultHandler{
    	//  Start Element Event Handler
    	public void startElement(
		 String uri,
		 String local,
			String qName,
			Attributes atts) {

    		if (qName.equals("eclipse.idReplacer")) {
    			try{
    				String pluginIds = atts.getValue("pluginIds");
    				
    				//parse value of pluginIDs
    				StringTokenizer tokenizer= new StringTokenizer(pluginIds,",");
    				while (tokenizer.hasMoreTokens()){
    					String element=tokenizer.nextToken();
    					String elementAndVersion=element+"_"+tokenizer.nextToken();
    					elements.put(element,elementAndVersion);
    					
    					//check for test.xml
    					File testXml=new File(buildDirectory+File.separator+"plugins"+File.separator+element+File.separator+"test.xml");
    					if (testXml.exists())
        					testElements.put(elementAndVersion,testXml);
    				} 								
    			} catch (Exception e){
    				e.printStackTrace();
       			}
 			} 
    	}
    }
 
    private class TestXmlHandler extends DefaultHandler{
    	String element;
    	
    	public TestXmlHandler(String element){
    		this.element=element;
    	}
    	//  Start Element Event Handler
    	public void startElement(
								 String uri,
								 String local,
								 String qName,
								 Attributes atts) {

    		String name=atts.getValue("name");
    		boolean isPerformanceTarget = false;
    		if (name!=null)
    			isPerformanceTarget= name.equals("performance");
    		    		
    		if (qName.equals("target") && isPerformanceTarget){
    				elements.put(element+".has.performance.target","true");
    		}
    	}
    }
    
	public void writeProperties(String propertiesFile,boolean append){
		
		identifyPerformancePlugins();
		
		try{
			
		PrintWriter writer = new PrintWriter(new FileWriter(propertiesFile,append));
				
			Object[] keys = elements.keySet().toArray();
			Arrays.sort(keys);
			for (int i=0;i<keys.length;i++){
				Object key = keys[i];
				writer.println(key.toString()+"="+elements.get(key).toString());
				writer.flush();
			}
			writer.close();
		
		} catch (IOException e){
			System.out.println("Unable to write to file "+propertiesFile);
		}
		
		
	}

	private void identifyPerformancePlugins() {
		Enumeration testElement=testElements.keys();
		while (testElement.hasMoreElements()){
			Object testPlugin=testElement.nextElement();
			String testXml=testElements.get(testPlugin).toString();
			parse(testXml,new TestXmlHandler(testPlugin.toString()));
		}
	}

	/**
	 * @return Returns the featurePath.
	 */
	public String getFeaturePath() {
		return featurePath;
	}

	/**
	 * @param featurePath The featurePath to set.
	 */
	public void setFeaturePath(String featurePath) {
		this.featurePath = featurePath;
	}

	/**
	 * @return Returns the installDirectory.
	 */
	public String getBuildDirectory() {
		return buildDirectory;
	}

	/**
	 * @param installDirectory The installDirectory to set.
	 */
	public void setBuildDirectory(String buildDirectory) {
		this.buildDirectory = buildDirectory;
	}

	/**
	 * @return Returns the outputFilePath.
	 */
	public String getOutputFilePath() {
		return outputFilePath;
	}

	/**
	 * @param outputFilePath The outputFilePath to set.
	 */
	public void setOutputFilePath(String outputFilePath) {
		this.outputFilePath = outputFilePath;
	}

}
