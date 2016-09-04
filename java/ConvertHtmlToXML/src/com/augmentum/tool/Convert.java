package com.augmentum.tool;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.FileReader;
import java.io.IOException;
import java.io.StringReader;
import java.io.StringWriter;
import java.util.HashMap;
import java.util.Map;

import javax.xml.parsers.DocumentBuilder;
import javax.xml.parsers.DocumentBuilderFactory;
import javax.xml.transform.OutputKeys;
import javax.xml.transform.TransformerFactory;
import javax.xml.transform.dom.DOMSource;
import javax.xml.transform.stream.StreamResult;

import org.w3c.dom.Document;
import org.w3c.dom.Element;
import org.w3c.dom.Node;
import org.w3c.dom.NodeList;
import org.xml.sax.InputSource;

public class Convert {
    private String htmlFile;
    private String xmlFile;
    private String htmlStr;
    private Document htmlDoc;
    private Document xmlDoc;
    private Map<String, String> htmlMap;

    public Convert(String htmlFile, String xmlFile) {
        if(htmlFile == null || xmlFile == null){
            throw new RuntimeException("input file or output file is required.");
        }
        this.htmlFile = htmlFile;
        this.xmlFile = xmlFile;
    }

    public void read() {
        readHTML();
        readXML();
    }

    public void convert() {
        convertHtmlStrToHtmlDocument();
        convertHtmlDocumentToHtmlMap();
        mergeHtmlToXml();
    }

    private void readHTML() {
        try {
            StringBuffer sb = new StringBuffer();
            FileReader reader = new FileReader(this.htmlFile);
            BufferedReader br = new BufferedReader(reader);
            String str = null;
            while ((str = br.readLine()) != null) {
                sb.append(str);
            }
            br.close();
            reader.close();
            this.htmlStr = sb.toString();
        } catch (FileNotFoundException e) {
            throw new RuntimeException("File " + this.htmlFile + " not found.");
        } catch (IOException e) {
            throw new RuntimeException("Failed to read " + this.htmlFile);
        }
    }

    private void convertHtmlStrToHtmlDocument() {
        int begin_index = this.htmlStr.indexOf("<dl>");
        int end_index = this.htmlStr.indexOf("</dl>");
        this.htmlStr = this.htmlStr.substring(begin_index, end_index + 5);
        try {
            StringReader sr = new StringReader(this.htmlStr);
            InputSource is = new InputSource(sr);
            DocumentBuilderFactory factory = DocumentBuilderFactory.newInstance();
            DocumentBuilder builder;
            builder = factory.newDocumentBuilder();
            this.htmlDoc = builder.parse(is);
        } catch (Exception e) {
            throw new RuntimeException("Convert " + this.xmlFile + " to document" + " failed.");
        }
    }

    private void readXML() {
        try {
            DocumentBuilderFactory dbf = DocumentBuilderFactory.newInstance();
            DocumentBuilder db = dbf.newDocumentBuilder();
            File outputFile = new File(this.xmlFile);
            if (outputFile.exists()) {
                this.xmlDoc = db.parse(this.xmlFile);
            } else {
                DocumentBuilderFactory factory = DocumentBuilderFactory.newInstance();
                DocumentBuilder builder = factory.newDocumentBuilder();
                this.xmlDoc = builder.newDocument(); 
                Element newNode = this.xmlDoc.createElement("properties");
                newNode.setAttribute("version", "1.0");
                this.xmlDoc.appendChild(newNode);
            }
        } catch (FileNotFoundException e) {
            throw new RuntimeException("File " + this.xmlFile + " not found.");
        } catch (Exception e) {
            throw new RuntimeException("Failed to read " + this.xmlFile);
        }
    }

    private void convertHtmlDocumentToHtmlMap() {
        this.htmlMap = new HashMap<String, String>();
        Element dlElement =this.htmlDoc.getDocumentElement();
        String key = null;
        for (int i = 0; i < dlElement.getChildNodes().getLength(); i++) {
            Node node = dlElement.getChildNodes().item(i);
            if ("dt".equals(node.getNodeName())) {
                key = node.getTextContent();
            } else if ("dd".equals(node.getNodeName())) {
                String value = null;
                try { value = node.getChildNodes().item(0).getTextContent(); } catch (Exception e) {}
                value = value.replaceAll("[\n\t]{1,}", " ");
                this.htmlMap.put(key, value);
                key = null;
            }
        }
    }

    private void mergeHtmlToXml() {
        Element rootElement =this.xmlDoc.getDocumentElement();
        NodeList nodes = rootElement.getChildNodes();
        for (int i = 0; i < nodes.getLength(); i++) {
            Element node = null;
            try {
                node = (Element)nodes.item(i);
            } catch (Exception e) {
                continue;
            }
            if ("entry".equals(node.getNodeName())) {
                String key = node.getAttribute("key");
                String value = node.getTextContent();
                if (this.htmlMap.containsKey(key) && !value.equals(this.htmlMap.get(key))) {
                    node.setTextContent(value);
                    this.htmlMap.remove(key);
                }
            }
        }
        for (String key : this.htmlMap.keySet()) {
            Element newNode = this.xmlDoc.createElement("entry");
            newNode.setAttribute("key", key);
            newNode.setTextContent(this.htmlMap.get(key));
            rootElement.appendChild(newNode);
        }
    }

    private String format(String originStr) {
        return originStr.replaceAll("\n<entry", "\n\t<entry");
    }

    public static String toStringFromDoc(Document document) {
        String result = null;
        if (document != null) {
            StringWriter strWtr = new StringWriter();
            StreamResult strResult = new StreamResult(strWtr);
            TransformerFactory tfac = TransformerFactory.newInstance();
            try {   
                javax.xml.transform.Transformer t = tfac.newTransformer();
                t.setOutputProperty(OutputKeys.ENCODING, "UTF-8");
                t.setOutputProperty(OutputKeys.INDENT, "yes");
                t.setOutputProperty(OutputKeys.METHOD, "xml");
                t.transform(new DOMSource(document.getDocumentElement()), strResult);
                result = strResult.getWriter().toString();
                strWtr.close();
            } catch (Exception e) {
                System.err.println("XML.toString(Document): " + e);
                throw new RuntimeException("Failed to parse XML document to string.");
            }
        }
        return result;
    }

    public void write() {
        String s = format(toStringFromDoc(this.xmlDoc));
        try {
            new FileOutputStream(new File(this.xmlFile)).write(s.getBytes());
        } catch (IOException e) {
            throw new RuntimeException("Failed to write XML document.");
        }
    }
}
