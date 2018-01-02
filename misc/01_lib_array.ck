public class Array {

    [0.] @=> float floats[];
    [0] @=> int ints[];
    string type;
    
    clear();

    private void switch_type(string new_type){
        if(new_type != "int" && new_type != "float"){
            <<<"unknown type:" + type>>>;
            return;
        }
        if(new_type == "int"){
            if(type == "int"){
                <<<"already of type int">>>;
            }
            else if(type == "float"){
                floats.size() => ints.size;
                for(0 => int i; i<floats.size(); i++){
                    floats[i]$int => ints[i];
                }
                floats.clear();
                "int" => type;
            }
        }
        else if(new_type == "float"){
            if(type == "float"){
                <<<"already of type float">>>;
            }
            else if(type == "int"){
                ints.size() => floats.size;
                for(0 => int i; i<ints.size(); i++){
                    ints[i] => floats[i];
                }
                ints.clear();
                "float" => type;
            }
        }
    }

    public void clear(){
        ints.clear();
        floats.clear();
        "int" => type;
    }


    public void append(int append_me){
        if(type == "float"){
            switch_type("int");
        }
        ints.size() +1 => ints.size;
        append_me => ints[ints.size()-1];
    }

    public void append(float append_me){
        if(type == "int"){
            switch_type("float");
        }
        floats.size() +1 => floats.size;
        append_me => floats[floats.size()-1];
    }


    public int pop_last(){
        return ints[ints.size()-1];
    }

    public float pop_last(){
        return ints[ints.size()-1];
    }

    

    public void print(){
        if(type == "int"){
            <<<"--- Array content ---">>>;
            for(0=>int i; i<ints.size(); i++){
                <<<i + ":" + ints[i]>>>;
            }
            <<<"---------------------">>>;
        }
        else if(type == "float"){
            <<<"--- Array content ---">>>;
            for(0=>int i; i<floats.size(); i++){
                <<<i + ":" + floats[i]>>>;
            }
            <<<"---------------------">>>;
        }
        else {
            <<<"array empty...">>>;
        }
            
    }



    public float quantize(float input, int scale[]){
        128 => float best_distance;
        float this_distance;
        0 => float best;
        int try;
        for(0=>int i; i<11; i++){
            for(0=>int j; j<scale.cap(); j++){
                scale[j]+i*12 => try;
                Std.fabs(try - input) => this_distance;
                if(this_distance < best_distance){
                    this_distance => best_distance;
                    try => best;
                }
            }
        }
        return best;
    }

    
    public int nextInScale(int current, int direction, int scale[]){
        int try, octave;
        
        if(direction > 0){
            0 => try;
            while(try < current){
                for(0=>octave; octave < 10; octave++){
                    for(0=>int i; i< scale.cap(); i++){
                        scale[i] + (octave * 12) => try;
                        if(try > current){
                            return try;
                        }
                    }
                    
                }
            }
        }
        else {
            200 => try;
            while(try > current){
                for(10=>octave; octave > 0; octave--){
                    for(scale.cap()-1 => int i; i>=0; i--){
                        scale[i] + (octave * 12) => try;
                        if(try < current){
                            return try;
                        }
                    }
                    
                }
            }
        }
    }    

        
    // Array, select random element
    public int array_random(int array[]){
        return array[Std.rand2(0,array.cap()-1)];
    }
    
    // Array, switch elements
    public static void array_switch(int array[], int i1, int i2){
        if(i1 != i2 && i1 < array.cap() && i2 < array.cap()){
            array[i1] => int tmp;
            array[i2] => array[i1];
            tmp => array[i2];
        }
    }

    public static void array_switch(int array[], int i1){
        Std.rand2(0,array.cap()-1) => int i2;
        array_switch(array, i1, i2);
    }
    
    public static void array_switch(int array[]){
        Std.rand2(0,array.cap()-1) => int i1;
        array_switch(array, i1);
    }
    
   
    public static void array_switch(float array[], int i1, int i2){
        if(i1 != i2 && i1 < array.cap() && i2 < array.cap()){
            array[i1] => float tmp;
            array[i2] => array[i1];
            tmp => array[i2];
        }
    }

    public static void array_switch(float array[], int i1){
        Std.rand2(0,array.cap()-1) => int i2;
        array_switch(array, i1, i2);
    }
    
    public static void array_switch(float array[]){
        Std.rand2(0,array.cap()-1) => int i1;
        array_switch(array, i1);
    }


    // Array printing, for debugging...
    public static void array_print(int array[]){
        for(0 => int i; i<array.cap(); i++){
            <<<array[i]>>>;
        }
    }
  
    public static void array_print(float array[]){
        for(0 => int i; i<array.cap(); i++){
            <<<array[i]>>>;
        }
    }
    
    
    

    
    public static int [] array_cat(int a1[], int a2[]){
        int result[a1.cap() + a2.cap()];
 
        0 => int j;
 
        for(0=>int i; i<a1.cap(); i++){
            a1[i] => result[j];
            j++;
        }
    
        for(0=>int i; i<a2.cap(); i++){
            a2[i] => result[j];
            j++;
        }

        return result;
    }

    public static int [] array_cat(int a1[]){
        return array_cat(a1,a1);
    }

    public static int [] array_merge(int a1[], int a2[]){
        int result[a1.cap() + a2.cap()];
    
        0 => int j;
    
        for(0=>int i;i<Math.max(a1.cap(),a2.cap());i++){
            if(i<a1.cap()){
                a1[i] => result[j];
                j++;
            }
            if(i<a2.cap()){
                a2[i] => result[j];
                j++;
            }
       
        }
        return result;
    }

    function int [] array_merge(int a1[]){
        return array_merge(a1,a1);
    }
    
    public static int in_array(float needle, float haystack[]){
        for(0=>int i; i< haystack.cap(); i++){
            if(needle == haystack[i]){
                return true;
            }
        }
        return false;
    }

    public static int in_array(int needle, int haystack[]){
        for(0=>int i; i< haystack.cap(); i++){
            if(needle == haystack[i]){
                return true;
            }
        }
        return false;
    }

    public static int in_array(int needle, float haystack[]){
        for(0=>int i; i< haystack.cap(); i++){
            if(needle == haystack[i]){
                return true;
            }
        }
        return false;
    }

    public static int in_array(float needle, int haystack[]){
        for(0=>int i; i< haystack.cap(); i++){
            if(needle == haystack[i]){
                return true;
            }
        }
        return false;
    }

    public static int in_array(string needle, string haystack[]){
        for(0=>int i; i< haystack.cap(); i++){
            if(needle == haystack[i]){
                return true;
            }
        }
        return false;
    }
    
}

10::week => now;