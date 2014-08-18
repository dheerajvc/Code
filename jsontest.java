package myclass;
import org.json.simple.JSONObject;
import org.json.simple.JSONArray;
import org.json.simple.parser.ParseException;
import org.json.simple.parser.JSONParser;
import java.io.BufferedReader;
import java.io.File;
import java.io.FileReader;
import java.io.IOException;

public class jsontest{
    public static void main(String args[]){
       BufferedReader reader=null;
       JSONParser parser=new JSONParser(); 
        try{  
        // create the buffered filereader
        File file = new File("/home/dheerajvc/test.json");
        reader = new BufferedReader(new FileReader(file));
        String line; 
        while((line= reader.readLine())!=null){
            //System.out.println(line);
            try{
               JSONObject obj = (JSONObject) parser.parse(line);
               System.out.println(obj.get("text"));
               }catch(ParseException pe){
                   System.out.println("position: " + pe.getPosition());
                   System.out.println(pe);
               }

            
        }
        }catch(IOException e){
            e.printStackTrace();
        }finally{
        try{
            reader.close();
        }catch(IOException e){
            e.printStackTrace();
            }
        }
    }
   
}
