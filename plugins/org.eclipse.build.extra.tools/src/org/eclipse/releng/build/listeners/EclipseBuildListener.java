package org.eclipse.releng.build.listeners;

/**
 * This build listener writes build progress based on target descriptions to a
 * build log (html page).
 * 
 */

import org.apache.tools.ant.BuildListener;
import org.apache.tools.ant.BuildEvent;

import java.io.*;
import java.util.Vector;
import org.eclipse.releng.BuildProperties;
import org.eclipse.releng.Mailer;

public class EclipseBuildListener implements BuildListener {

	private String logFile;
	private PrintWriter out;
	private Vector messages;
	private Mailer mailer;
	private BuildProperties buildProperties;
	private String subjectPrefix;

	private void openPrintWriter(boolean append) {
		try {
			out = new PrintWriter(new FileWriter(logFile, append));
		} catch (IOException e) {
			System.out.println("Unable to write to build log.");
			e.printStackTrace();
		}
	}

	public EclipseBuildListener() {
		messages = new Vector();
		buildProperties =  new BuildProperties();
		logFile = buildProperties.getLogFile();
		try {
			mailer = new Mailer();
		} catch (NoClassDefFoundError e) {
			System.out.println("j2ee.jar may not be on the Ant classpath.");
		}
	}

	public void targetStarted(BuildEvent event) {

		String description = event.getTarget().getDescription();
		if (description != null) {
			messages.add(description);
			printLog();
		}

		if (event.getException() != null) {
			printStackTrace(event);
		}
	}

	public void buildFinished(BuildEvent event) {
		if (event.getException() != null && mailer != null) {
			mailer.sendMessage(
				" Build failed",
				event.getException().getMessage()+"\n\n"+buildProperties.getDownloadUrl()+"/"+buildProperties.getBuildLabel());
		} 
	}

	private void printStackTrace(BuildEvent event) {
		printHead(
			"Build "
				+ buildProperties.getBuildid()
				+ " ("
				+ buildProperties.getTimestamp()
				+ ")"
				+ " failed!");
		openPrintWriter(true);
		for (int i = 0; i < messages.size(); i++)
			out.println(
				"&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;" + messages.get(i) + "<br>");
		out.flush();
		out.close();

		openPrintWriter(true);
		out.println("<br><pre>");
		event.getException().printStackTrace(out);
		out.println("</pre>");
		out.flush();
		out.close();
		printTail();
	}

	private void printHead(String header) {
		openPrintWriter(false);
		out.println("<html><head><title>" + header + "</title>");
		out.println(
			"<meta http-equiv=\"Content-Type\" content=\"text/html; charset=iso-8859-1\">");
		out.println(
			"<link rel=\"stylesheet\" href=\"../../../default_style.css\" type=\"text/css\">");
		out.println("</head>");
		out.println("<body>");
		out.println("<h3>" + header + "<br></h3>");
		out.flush();
		out.close();
	}

	private void printTail() {
		openPrintWriter(true);
		out.println("</body></html>");
		out.flush();
		out.close();
	}

	private void printLog() {
		printHead(
			"Build "
				+ buildProperties.getBuildid()
				+ " ("
				+ buildProperties.getTimestamp()
				+ ")"
				+ " in progress");
		openPrintWriter(true);
		for (int i = 0; i < messages.size(); i++)
			out.println(
				"&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;" + messages.get(i) + "<br>");
		out.flush();
		out.close();
		printTail();
	}

	public void targetFinished(BuildEvent event) {
		if (event.getException() != null)
			printStackTrace(event);
	}
	public void buildStarted(BuildEvent event) {
	}
	public void taskStarted(BuildEvent event) {
	}
	public void taskFinished(BuildEvent event) {
	}
	public void messageLogged(BuildEvent event) {
	}

}
