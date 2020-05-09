<?php
declare(strict_types=1);

namespace Plaisio\RequestLogger;

use Plaisio\C;
use Plaisio\Kernel\Nub;

/**
 * A HTTP page request logger for light and development websites.
 */
class RequestLoggerLight implements RequestLogger
{
  //--------------------------------------------------------------------------------------------------------------------
  /**
   * If true the HTTP page request details (i.e. cookies, post variables and queries) must be logged.
   *
   * @var bool
   *
   * @api
   * @since 1.0.0
   */
  public $logRequestDetails;

  /**
   * If true the HTTP page request must be logged.
   *
   * @var bool
   *
   * @api
   * @since 1.0.0
   */
  public $logRequests;

  /**
   * The ID of the logged page request.
   *
   * @var int|null
   *
   * @api
   * @since 1.0.0
   */
  public $rqlId;

  //--------------------------------------------------------------------------------------------------------------------
  /**
   * Object constructor.
   */
  public function __construct()
  {
    $this->logRequests       = true;
    $this->logRequestDetails = false;
  }

  //--------------------------------------------------------------------------------------------------------------------
  /**
   * Logs the HTTP page request.
   *
   * @param int|null $status The HTTP status code.
   *
   * @api
   * @since 1.0.0
   */
  public function logRequest(?int $status): void
  {
    if ($this->logRequests)
    {
      $time0 = Nub::$nub->request->getRequestTime();

      $this->rqlId = Nub::$nub->DL->abcRequestLoggerLightInsertRequest(
        Nub::$nub->session->getSesId(),
        Nub::$nub->companyResolver->getCmpId(),
        Nub::$nub->session->getUsrId(),
        Nub::$nub->requestHandler->getPagId(),
        mb_substr(Nub::$nub->request->getRequestUri() ?? '', 0, C::LEN_RQL_REQUEST),
        mb_substr(Nub::$nub->request->getMethod() ?? '', 0, C::LEN_RQL_METHOD),
        mb_substr(Nub::$nub->request->getReferrer() ?? '', 0, C::LEN_RQL_REFERRER),
        Nub::$nub->request->getRemoteIp(),
        mb_substr(Nub::$nub->request->getAcceptLanguage() ?? '', 0, C::LEN_RQL_ACCEPT_LANGUAGE),
        mb_substr(Nub::$nub->request->getUserAgent() ?? '', 0, C::LEN_RQL_USER_AGENT),
        $status,
        count(Nub::$nub->DL->getQueryLog()),
        ($time0!==null) ? microtime(true) - $time0 : null);

      if ($this->logRequestDetails)
      {
        $oldLogQueries            = Nub::$nub->DL->logQueries;
        Nub::$nub->DL->logQueries = false;

        $this->requestLogQuery();
        $this->requestLogPost($_POST);
        $this->requestLogCookie($_COOKIE);

        Nub::$nub->DL->logQueries = $oldLogQueries;
      }
    }
  }

  //--------------------------------------------------------------------------------------------------------------------
  /**
   * Logs the (by the user agent) sent cookies into the database.
   *
   * Usage on this method on production environments is not recommended.
   *
   * @param array       $cookies    must be $_COOKIES
   * @param string|null $parentName must not be used, intended for use by recursive calls only.
   */
  private function requestLogCookie(array $cookies, ?string $parentName = null): void
  {
    if (is_array($cookies))
    {
      foreach ($cookies as $name => $value)
      {
        $fullName = ($parentName===null) ? (string)$name : $parentName.'['.$name.']';

        if (is_array($value))
        {
          $this->requestLogCookie($value, $fullName);
        }
        else
        {
          Nub::$nub->DL->abcRequestLoggerLightInsertCookie($this->rqlId, $fullName, $value);
        }
      }
    }
  }

  //--------------------------------------------------------------------------------------------------------------------
  /**
   * Logs the post variables into the database.
   *
   * Usage on this method on production environments is not recommended.
   *
   * @param array       $post       Must be $_POST (except for recursive calls).
   * @param string|null $parentName Must not be used (except for recursive calls).
   */
  private function requestLogPost(array $post, ?string $parentName = null): void
  {
    if (is_array($post))
    {
      foreach ($post as $name => $value)
      {
        $fullName = ($parentName===null) ? (string)$name : $parentName.'['.$name.']';

        if (is_array($value))
        {
          $this->requestLogPost($value, $fullName);
        }
        else
        {
          // Don't log passwords.
          if (is_string($name) && strpos($name, 'password')!==false)
          {
            $value = str_repeat('*', mb_strlen($name));
          }

          Nub::$nub->DL->abcRequestLoggerLightInsertPost($this->rqlId, $fullName, $value);
        }
      }
    }
  }

  //--------------------------------------------------------------------------------------------------------------------
  /**
   * Logs the executed SQL queries into the database.
   */
  private function requestLogQuery(): void
  {
    $queries = Nub::$nub->DL->getQueryLog();

    foreach ($queries as $query)
    {
      Nub::$nub->DL->abcRequestLoggerLightInsertQuery($this->rqlId, $query['query'], $query['time']);
    }
  }

  //--------------------------------------------------------------------------------------------------------------------
}

//----------------------------------------------------------------------------------------------------------------------
