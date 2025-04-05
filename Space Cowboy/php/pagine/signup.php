<?php
    require_once "../utils/db_parameter.php";
    require_once "../utils/db_connect.php";
    
    
    $msg = "";
    $valido = false;
    if($_SERVER["REQUEST_METHOD"] === "POST"){
        $connection = db_connect();
        $user = $_POST["userSignup"];
        $pwd = $_POST["passSignup"];
        $rep_pwd = $_POST["reppassSignup"];
        $msg = validate($user,$pwd,$rep_pwd);
        if($msg === ""){
            // controllo dello username che non deve essere presente 
            $stmt = mysqli_prepare($connection, "SELECT *
                                                FROM utenti u
                                                WHERE u.username = ?");
            mysqli_stmt_bind_param($stmt,"s",$user);
            if(!mysqli_stmt_execute($stmt)){
                mysqli_stmt_close($stmt);
                $msg = "errore nell'esecuzione";
            } else {
                $res = mysqli_stmt_get_result($stmt);
                if(mysqli_num_rows($res) != 0){
                    mysqli_stmt_close($stmt);
                    $msg = "username già presente";
                } else {
                    // controlli passati ora devo aggiungere il sale 
                    $salt = base64_encode(random_bytes(12));
                    $hash = password_hash($pwd . $salt,PASSWORD_BCRYPT);
                    $stmt = mysqli_prepare($connection, "INSERT INTO utenti (username,password_hash,salt)
                                                     VALUES (?,?,?)");
                    mysqli_stmt_bind_param($stmt,"sss",$user,$hash,$salt);   
                    if(!mysqli_stmt_execute($stmt)){     
                        $msg = "errore nell'esecuzione";
                    } else {
                        $msg = "registrazione completata";
                        $valido = true;
                    }
                    mysqli_stmt_close($stmt);
                }
            }
        }
    }

    function validate($user,$pwd,$rep_pwd){
        $regExpU = "/^[A-Za-z0-9]{3,18}$/";
        $regExpPass = "/^(?=.*\d)(?=.*[^a-zA-Z0-9\s]).{8,18}$/";
        $messaggio = "";
        if(!preg_match($regExpU,$user)){
            $messaggio = $messaggio."il formato dello username è sbagliato ";
        }
        if(!preg_match($regExpPass,$pwd)){
            $messaggio = $messaggio."il formato della password è sbagliato ";
        }
        if($pwd !== $rep_pwd){
            $messaggio = $messaggio."le due password non combaciano";
        }
        return $messaggio;
    }
?>
<!DOCTYPE html>
<html lang = "it">
    <head>
        <meta charset = "utf-8">
        <title>Space Cowboy Flight Finder</title>
        <link rel = "stylesheet" href = "../../css/NavBar.css">
        <link rel = "stylesheet" href = "../../css/signup.css">
        <script src = "../../js/signup.js"></script>
        <meta name = "viewport" content = "width = device-width">
        <meta name = "author" content = "Francesco Vesigna">
        <meta name = "description" content = "Signup page of the website">
    </head> 
    <body onload = "init()">
        <div id = "wrapper">
            <div id = "title">
                <h1>Space Cowboy</h1>
            </div>
            <div id = "NavBar">
                <a href = "home.php"> Home </a>
                <a href = "../../html/guida.html"> Guida </a>
            </div>
        </div> 
        <div id="form">
            <form id="signup"  method="POST">
                <h2>Signup</h2>
                <div>
                    <label for="userSignup">Username</label>
                    <input type="text" id="userSignup" name="userSignup" required>
                    <span id="usernameFormat" class="formatMessage">Username: 3-18 caratteri, lettere e numeri</span>
                </div>
                <div>
                    <label for="passSignup">Password</label>
                    <input type="password" id="passSignup" name="passSignup" required>
                    <span id="passwordFormat" class="formatMessage">Password: 8-18 caratteri, almeno un numero e un carattere speciale</span>
                </div>
                <div>
                    <label for="reppassSignup">Conferma Password</label>
                    <input type="password" id="reppassSignup" name="reppassSignup" required>
                    <span id="confirmPasswordFormat" class="formatMessage">Conferma la password inserita</span>
                </div>
                <div id="pulsantiera">
                    <input type="submit" id="pulSignup" value="Registrati">
                </div>
                <?php if($msg !== ""):?>
                    <p id="msg" class = <?php 
                     if($valido === false){
                         echo "invalido";
                     } else {
                         echo "valido";
                     } ?>><?php echo $msg?></p>
                <?php endif; ?>
                <a href = "login.php"> Hai già un account? </a>
            </form>
        </div>
    </body>
</html>
