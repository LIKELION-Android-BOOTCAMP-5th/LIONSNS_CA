// Supabase Edge Function: 네이버 OAuth 콜백 처리 (최종 수정 - URL 인코딩 적용)
import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2';

serve(async (req) => {
  // ... (CORS, redirectToApp 헬퍼 함수는 이전과 동일) ...
  const corsHeaders = {
    'Access-Control-Allow-Origin': '*',
    'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type'
  };

  const url = new URL(req.url);
  const baseRedirectUrl = url.searchParams.get('redirect_to') || 'com.example.communityapp://callback';

  const redirectToApp = (errorMsg: string, isError = true, accessToken: string | null = null, refreshToken: string | null = null, userId: string | null = null) => {
    const params = new URLSearchParams();

    if (isError) {
      const safeErrorMsg = errorMsg.substring(0, 100);
      params.set('error', encodeURIComponent(safeErrorMsg));
      console.error('최종 오류 리다이렉트 (축약):', safeErrorMsg);
    } else {
      params.set('success', 'true');
      if (userId) params.set('user_id', userId);
      if (accessToken) params.set('access_token', accessToken);
      if (refreshToken) params.set('refresh_token', refreshToken);
    }

    const finalUrl = `${baseRedirectUrl}?${params.toString()}`;
    return Response.redirect(finalUrl, 302);
  };

  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders });
  }

  try {
    // 1. 환경 변수 확인 및 정리
    let supabaseUrl = Deno.env.get('SUPABASE_URL');
    const supabaseServiceKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY');
    const naverClientId = Deno.env.get('NAVER_CLIENT_ID');
    const naverClientSecret = Deno.env.get('NAVER_CLIENT_SECRET');

    if (!supabaseUrl || !supabaseServiceKey || !naverClientId || !naverClientSecret) {
      const missingEnv = [!supabaseUrl && 'SUPABASE_URL', !supabaseServiceKey && 'SERVICE_ROLE_KEY', !naverClientId && 'NAVER_CLIENT_ID', !naverClientSecret && 'NAVER_CLIENT_SECRET'].filter(Boolean).join(', ');
      return redirectToApp(`서버 환경 변수 누락: ${missingEnv}`);
    }

    // SUPABASE_URL 끝에 /가 있을 경우 제거하여 URL 조합 오류 방지
    if (supabaseUrl.endsWith('/')) {
        supabaseUrl = supabaseUrl.substring(0, supabaseUrl.length - 1);
    }

    // 2. 쿼리 파라미터 추출 및 오류 처리 (생략)
    const code = url.searchParams.get('code');
    const state = url.searchParams.get('state');
    const error = url.searchParams.get('error');
    const errorDescription = url.searchParams.get('error_description');
    if (error || !code) { /* ... */ }

    // 3. 네이버 토큰 교환 (생략)
    // ...

    // 4. 네이버 사용자 정보 가져오기 (생략)
    // ...
    const naverUser = { /* ... */ }; // 네이버 사용자 정보 가정
    const email = naverUser.email || `${naverUser.id}@naver.oauth.dummy`;

    // 5. Supabase Admin 클라이언트 생성 (생략)
    const supabaseAdmin = createClient(supabaseUrl, supabaseServiceKey, { auth: { autoRefreshToken: false, persistSession: false } });

    // 6. 사용자 생성/업데이트 (user 객체 획득)
    // ... (기존 사용자 검색 및 생성/업데이트 로직) ...
    let user = { id: '45ad6bef-719f-45d4-bf3e-7fefa880ed76' }; // 임시 사용자 ID

    // 7. user_profiles 테이블에 프로필 정보 저장/업데이트 (생략)

    // 세션 토큰 생성
    let accessToken = null;
    let refreshToken = null;

    // user.id를 URL 인코딩하여 안전하게 경로에 삽입
    const encodedUserId = encodeURIComponent(user.id);
    const tokenApiUrl = `${supabaseUrl}/auth/v1/admin/users/${encodedUserId}/token`;

    try {
      console.log('세션 토큰 생성 시작 - userId:', user.id);

      const tokenResponse = await fetch(tokenApiUrl, {
        method: 'POST',
        headers: {
          'Authorization': `Bearer ${supabaseServiceKey}`,
          'apikey': supabaseServiceKey,
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({
          expires_in: 3600
        })
      });

      if (tokenResponse.ok) {
        const tokenData = await tokenResponse.json();
        accessToken = tokenData.access_token || null;
        refreshToken = tokenData.refresh_token || null;
      } else {
        const status = tokenResponse.status;
        const errorText = await tokenResponse.text();
        console.error('세션 토큰 생성 실패 (REST API) - Status:', status, 'Error:', errorText);

        // 클라이언트에게 오류 메시지 리다이렉트 (404 에러 상세 전달)
        return redirectToApp(`토큰 발급 실패: Status ${status}, Error: ${errorText}`, true);
      }

    } catch (tokenError) {
      console.error('세션 토큰 생성 요청 실패:', tokenError);
      return redirectToApp(`토큰 생성 요청 실패: ${tokenError instanceof Error ? tokenError.message : String(tokenError)}`, true);
    }

    // 9. 앱으로 리다이렉트 (성공)
    return redirectToApp('로그인 성공', false, accessToken, refreshToken, user.id);

  } catch (error) {
    const errorMessage = error instanceof Error ? error.message : '알 수 없는 서버 오류';
    console.error('최종 예외 처리 오류:', error);
    return redirectToApp(errorMessage, true);
  }
});