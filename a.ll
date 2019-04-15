
; <label>:18:                                     ; preds = %14
   %19 = load i32, i32* %6, align 4, !tbaa !2
   %20 = add nsw i32 %19, 1
   store i32 %20, i32* %6, align 4, !tbaa !2
   br label %10

; <label>:18:                                     ; preds = %14
  %19 = load i32, i32* %6, align 4, !tbaa !2
  %20 = call i32 @__faultinject_selected_target(i32 %19)
  %21 = add nsw i32 %20, 1
  store i32 %21, i32* %6, align 4, !tbaa !2
  br label %10

; <label>:22:                                     ; preds = %10
  %23 = load i32, i32* %7, align 4, !tbaa !2
  %24 = call i32 (i8*, ...) @printf(i8* getelementptr inbounds ([3 x i8], [3 x i8]* @.str, i32 0, i32 0), i32 %23)
  %25 = bitcast i32* %7 to i8*
  call void @llvm.lifetime.end.p0i8(i64 4, i8* %25) #3
  %26 = bitcast i32* %6 to i8*
  call void @llvm.lifetime.end.p0i8(i64 4, i8* %26) #3
  %27 = load i32, i32* %3, align 4
  ret i32 %27
}

; Function Attrs: argmemonly nounwind
declare void @llvm.lifetime.start.p0i8(i64, i8* nocapture) #1

declare dso_local void @__marking_faultinject_ptr(i32*) #2

declare dso_local i32 @printf(i8*, ...) #2
