/**
 * Parses feature.xml, plugin.xml, and fragment.xml files
 *
 */

package org.eclipse.releng;
import org.apache.xerces.parsers.SAXParser;
import org.xml.sax.Attributes;
import org.xml.sax.helpers.DefaultHandler;
import org.xml.sax.SAXException;
import java.io.IOException;
import java.util.Vector;
import java.io.File;
import org.apache.tools.ant.BuildException;


public class ElementParser extends DefaultHandler {

	private SAXParser parser;
	private Vector plugins;	
	private Vector features;

	public Vector getPlugins(){return plugins;}
	public Vector getFeatures(){return features;}

    public ElementParser() {
        //  Create a Xerces SAX Parser
        parser = new SAXParser();
        
        //  Set Content Handler
        parser.setContentHandler (this);
        
        // instantiate vectors that will hold lists of plugins and features read from feature.xml
        plugins = new Vector();
        features = new Vector();
    }
    
    public void parse(String xmlFile){
			
	    //  Parse the Document      
        try {
            parser.parse(xmlFile);
        } catch (SAXException e) {
            System.err.println (e);
        } catch (IOException e) {
            System.err.println (e);
          
        }
    }

	public void parse(String install, String type, String id){
				
		String xmlFile=null;		
		
		if (type.equals("feature"))
			xmlFile=install+"/features/"+id+"/"+"feature.xml";
		if (type.equals("plugin"))
			xmlFile=install+"/plugins/"+id+"/"+"plugin.xml";
		if (type.equals("fragment"))
			xmlFile=install+"/plugins/"+"/"+id+"/"+"fragment.xml";

		if (new File(xmlFile).exists())	
			parse(xmlFile);
		
		else{
			throw new BuildException("The following "+type+" "+id+" did not get fetched.");
		}
	
	}
    
    //  Start Element Event Handler
    public void startElement (String uri, String local,
        String qName, Attributes atts)  {
        if (local.equals("plugin")||local.equals("fragment"))
    		add(atts.getValue("id"), plugins);
    	if (local.equals("feature"))
    		add(atts.getValue("id")+"-feature", features);
    }
    
    public void add(String element, Vector v){
    	if (!v.contains(element))
    		v.add(element);
    }
    
    // Test
    public static void main (String[] args) {
        ElementParser xmlParser = new ElementParser();
        xmlParser.parse("l:/vabase/team/sonia", "feature", "org.eclipse.platform-feature");
        xmlParser.parse("l:/vabase/team/sonia", "feature", "org.eclipse.platform.win32-feature");
        xmlParser.parse("l:/vabase/team/sonia", "feature", "org.eclipse.platform.linux.motif-feature");
        xmlParser.parse("l:/vabase/team/sonia", "feature", "org.eclipse.platform.linux.gtk-feature");
        xmlParser.parse("l:/vabase/team/sonia", "feature", "org.eclipse.platform.solaris.motif-feature");
        xmlParser.parse("l:/vabase/team/sonia", "feature", "org.eclipse.platform.aix.motif-feature");
        xmlParser.parse("l:/vabase/team/sonia", "feature", "org.eclipse.platform.qnx.photon-feature");
        xmlParser.parse("l:/vabase/team/sonia", "feature", "org.eclipse.jdt-feature");
        xmlParser.parse("l:/vabase/team/sonia", "feature", "org.eclipse.pde-feature");
        xmlParser.parse("l:/vabase/team/sonia", "feature", "org.eclipse.sdk.examples-feature");
        xmlParser.parse("l:/vabase/team/sonia", "feature", "org.eclipse.sdk.tests-feature");

        xmlParser.parse("l:/vabase/team/sonia", "feature", "org.eclipse.platform.source-feature");
        xmlParser.parse("l:/vabase/team/sonia", "feature", "org.eclipse.platform.win32.source-feature");
        xmlParser.parse("l:/vabase/team/sonia", "feature", "org.eclipse.platform.linux.motif.source-feature");
        xmlParser.parse("l:/vabase/team/sonia", "feature", "org.eclipse.platform.linux.gtk.source-feature");
        xmlParser.parse("l:/vabase/team/sonia", "feature", "org.eclipse.platform.solaris.motif.source-feature");
        xmlParser.parse("l:/vabase/team/sonia", "feature", "org.eclipse.platform.aix.motif.source-feature");
        xmlParser.parse("l:/vabase/team/sonia", "feature", "org.eclipse.platform.qnx.photon.source-feature");
        xmlParser.parse("l:/vabase/team/sonia", "feature", "org.eclipse.jdt.source-feature");

        System.out.println(xmlParser.plugins);
        System.out.println(xmlParser.features);
        
        System.out.println(xmlParser.plugins.size()+" plugins expected");
        System.out.println(xmlParser.features.size()+" features expected");
    }
}
