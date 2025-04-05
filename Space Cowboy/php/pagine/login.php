<?php
    require_once "../utils/db_parameter.php";
    require_once "../utils/db_connect.php";
    
    $msg = "";
    if($_SERVER["REQUEST_METHOD"] === "POST"){
        $user = $_POST["userLogin"];
        $pass = $_POST["passLogin"];
        $connection = db_connect();
        $stmt = mysqli_prepare($connection, "SELECT *
                                             FROM utenti u
                                             WHERE u.username = ?");
        mysqli_stmt_bind_param($stmt,"s",$user);
        if(!mysqli_stmt_execute($stmt)){
            $msg = "errore nell'esecuzione";
        } else {
            $res = mysqli_stmt_get_result($stmt);
            if(mysqli_num_rows($res) === 0){
                // credenziali errate
                $msg = "credenziali errate";

            } else {
                // è unico dunque c'è solo un record
                $row = mysqli_fetch_assoc($res);
                $hashed = $row["password_hash"];
                $salt = $row["salt"];
                if(!password_verify($pass.$salt,$hashed)){
                    $msg = "credenziali errate";
                } else{
                    // rigeneriamo l'id 
                    session_start();
                    session_regenerate_id();
                    $_SESSION["username"] = $row["username"]; 
                    header("location: home.php");
                }
                
            }
        }
        mysqli_stmt_close($stmt);
    }
?>


<!DOCTYPE html>
<html lang = "it">
    <head>
        <meta charset = "utf-8">
        <title>Space Cowboy Flight Finder</title>
        <link rel = "stylesheet" href = "../../css/NavBar.css">
        <link rel = "stylesheet" href = "../../css/login.css">
        <meta name = "viewport" content = "width = device-width">
        <meta name = "author" content = "Francesco Vesigna">
        <meta name = "description" content = "Login page of the Website">
    </head> 
    <body>
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
            <form id="login" method="POST">
                <h2>Login</h2>
                <div>
                    <label for="userLogin">Username</label>
                    <input type="user" id="userLogin" name="userLogin">
                </div>
                <div>
                    <label for="passLogin">Password</label>
                    <input type="password" id="passLogin" name="passLogin">
                </div>
                <div id="pulsantiera">
                    <input type="submit" id="pulLogin" value="Accedi">
                </div>
                <a href="signup.php">Non hai un account?</a>
                <?php if($msg !== ""):?>
                    <p id = "msg"> <?php echo $msg ?></p>
                <?php endif; ?>
            </form>
        </div>
    </body>
</html>