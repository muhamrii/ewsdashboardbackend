<?php

function sendMessage($chatID, $messaggio, $token) {
    echo "sending message to " . $chatID . "\n";


    $url = "https://api.telegram.org/" . $token . "/sendMessage?chat_id=" . $chatID;
//    $url = "https://149.154.167.220/" . $token . "/sendMessage?chat_id=" . $chatID;
    $url = $url . "&text=" . urlencode($messaggio);
    $ch = curl_init();
    $optArray = array(
            CURLOPT_URL => $url,
            CURLOPT_RETURNTRANSFER => true
    );
    curl_setopt_array($ch, $optArray);
    curl_setopt($ch, CURLOPT_SSL_VERIFYPEER, FALSE);
    $result = curl_exec($ch);
    curl_close($ch);
    echo $result;
}

function generatePDF($txtfile, $pdffile, $region)
        {
                $region = $region." ";
                $file = "$txtfile";
                $fp = @fopen($file, 'r');
                // Add each line to an array
                if ($fp) {
                   $data = explode("\n", fread($fp, filesize($file)));
                }
                //print_r($data);

                //$pdf = new FPDF();
                //$pdf = new FPDF('P','mm','A4');
                $pdf = new FPDF('P','mm',array(135,250));
                $pdf->AddPage();
                $pdf->SetFont('Arial','',12);
                //$pdf->Cell(40,10,'Alarm License Details :');
                $pdf->write(5,$region);
                $pdf->write(5,'status :');
                $pdf->ln();
                $pdf->ln();
                foreach ($data as $line) {
                //$pdf->Cell(40,10,$line');
                $pdf->write(5, $line);
                $pdf->ln();
                $pdf->ln();
                }
                $pdf->write(5, "");
                $pdf->Output('F',$pdffile);
                echo "$pdffile  generated";
        }

function sendDoc($chatID, $file, $token) {
                echo "sending message to " . $chatID . "\n";
                $messaggio = "Test_Logo";

                $url = "https://api.telegram.org/" . $token . "/sendDocument?chat_id=" . $chatID;
                //$url = "https://149.154.167.220/" . $token . "/sendDocument?chat_id=" . $chatID;
                $url = $url . "&text=" . urlencode($messaggio);
                $post_fields = array('chat_id'   => $chat_id,
                  'document'     => new CURLFile(realpath($file))
                );


                $ch = curl_init();
                $optArray = array(
                                CURLOPT_URL => $url,
                                CURLOPT_RETURNTRANSFER => true
                );
                curl_setopt_array($ch, $optArray);
                curl_setopt($ch, CURLOPT_SSL_VERIFYPEER, FALSE);
                curl_setopt($ch, CURLOPT_HTTPHEADER, array(
                "Content-Type:multipart/form-data"));
                curl_setopt($ch, CURLOPT_RETURNTRANSFER, 1);
                curl_setopt($ch, CURLOPT_POSTFIELDS, $post_fields);
                $result = curl_exec($ch);
                curl_close($ch);
                echo $result;
        }


$token = $argv[1];
$chatid = "-".$argv[2];
$server = $argv[3];
$myfile1 = file_get_contents("/home/muhamri1998/script/ewsrmsdashboard/BACKEND_SCRIPT/SUMMARY_EWS/". $server .".txt");
$msg1 = urlencode($myfile1);
$msg1 = $myfile1;
sendMessage($chatid,$msg1, $token);
?>
