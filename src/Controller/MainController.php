<?php

namespace App\Controller;

use Symfony\Bundle\FrameworkBundle\Controller\AbstractController;
use Symfony\Component\HttpFoundation\Response;

/**
 * Class MainController
 *
 * @author phuc vo <phucwan@gmail.com>
 */
class MainController extends AbstractController
{
    /**
     * @return Response
     */
    public function home(): Response
    {
        echo '<h2> Hey :D </h2>';

        return new Response();
    }
}
